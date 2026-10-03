package checkutil

import (
	"bytes"
	"context"
	"encoding/json/v2"
	"fmt"
	"net"
	"os"
	"os/exec"
	"strings"
	"sync"
	"syscall"
	"testing"
	"time"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

const collectorBin = "otelcol-contrib"

type syncBuffer struct {
	mu  sync.Mutex
	buf bytes.Buffer
}

func (b *syncBuffer) Write(p []byte) (int, error) {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.buf.Write(p)
}

func (b *syncBuffer) String() string {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.buf.String()
}

// FreePort asks the kernel for an unused TCP port on 127.0.0.1.
func FreePort(t testing.TB) int {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer l.Close()
	return l.Addr().(*net.TCPAddr).Port
}

// Validate runs `otelcol-contrib validate` on the config file and fails the test on error.
func Validate(t testing.TB, config string, env ...string) {
	t.Helper()
	cmd := exec.Command(collectorBin, "validate", "--config=file:"+config)
	cmd.Env = append(os.Environ(), env...)
	if out, err := cmd.CombinedOutput(); err != nil {
		msg := strings.TrimSpace(string(out))
		if strings.Contains(msg, `unknown type: "otlp_`) {
			msg += "\n(your otelcol-contrib predates the otlp_grpc/otlp_http exporter names; get a current release)"
		}
		t.Fatalf("%s validate --config %s failed:\n%s", collectorBin, config, msg)
	}
}

// ResolvedConfig returns the collector's view of the config (print-config --format json).
func ResolvedConfig(t testing.TB, config string, env ...string) map[string]any {
	t.Helper()
	Validate(t, config, env...)
	cmd := exec.Command(collectorBin, "print-config", "--format=json", "--config=file:"+config)
	cmd.Env = append(os.Environ(), env...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	out, err := cmd.Output()
	if err != nil {
		t.Fatalf("print-config failed: %v\n%s", err, stderr.String())
	}
	var m map[string]any
	if err := json.Unmarshal(out, &m); err != nil {
		t.Fatalf("print-config output is not JSON: %v", err)
	}
	return m
}

// Dig walks nested maps by key, returning nil when any step is missing.
func Dig(m any, keys ...string) any {
	for _, k := range keys {
		mm, ok := m.(map[string]any)
		if !ok {
			return nil
		}
		m = mm[k]
	}
	return m
}

// Collector is a running otelcol-contrib whose stderr (where the debug exporter writes) is captured.
type Collector struct {
	// Endpoint is the OTLP/HTTP base URL, e.g. http://127.0.0.1:43127.
	Endpoint string
	out      *syncBuffer
}

// StartCollector validates and starts the collector with config. The receiver named
// `otlp` is moved to free ports so checks never clash with anything already on 4317/4318.
func StartCollector(t testing.TB, config string, env ...string) *Collector {
	t.Helper()
	Validate(t, config, env...)
	httpPort, grpcPort := FreePort(t), FreePort(t)
	ctx, cancel := context.WithCancel(context.Background())
	cmd := exec.CommandContext(ctx, collectorBin,
		"--config=file:"+config,
		fmt.Sprintf("--set=receivers::otlp::protocols::http::endpoint=127.0.0.1:%d", httpPort),
		fmt.Sprintf("--set=receivers::otlp::protocols::grpc::endpoint=127.0.0.1:%d", grpcPort),
		"--set=service::telemetry::metrics::level=none",
	)
	cmd.Env = append(os.Environ(), env...)
	out := &syncBuffer{}
	cmd.Stdout, cmd.Stderr = out, out
	cmd.Cancel = func() error { return cmd.Process.Signal(syscall.SIGTERM) }
	cmd.WaitDelay = 5 * time.Second
	if err := cmd.Start(); err != nil {
		cancel()
		t.Fatalf("starting %s: %v", collectorBin, err)
	}
	exited := make(chan struct{})
	go func() {
		cmd.Wait()
		close(exited)
	}()
	t.Cleanup(func() {
		cancel()
		<-exited
	})

	addr := fmt.Sprintf("127.0.0.1:%d", httpPort)
	deadline := time.Now().Add(15 * time.Second)
	for {
		select {
		case <-exited:
			t.Fatalf("the collector exited during startup:\n%s", tail(out.String(), 30))
		default:
		}
		if c, err := net.DialTimeout("tcp", addr, 200*time.Millisecond); err == nil {
			c.Close()
			break
		}
		if time.Now().After(deadline) {
			t.Fatalf("the otlp receiver never listened on %s; does your config have an `otlp` receiver with the http protocol in a pipeline?\n%s", addr, tail(out.String(), 30))
		}
		time.Sleep(50 * time.Millisecond)
	}
	col := &Collector{Endpoint: "http://" + addr, out: out}
	for l := range strings.SplitSeq(out.String(), "\n") {
		if strings.Contains(l, "alias is deprecated") {
			_, msg, _ := strings.Cut(l, "\t\"")
			msg, _, _ = strings.Cut(msg, "\t")
			t.Errorf("the collector warns: \"%s", msg)
		}
	}
	return col
}

// Output is everything the collector has logged so far.
func (c *Collector) Output() string { return c.out.String() }

// Tail is the last n lines of the collector's output.
func (c *Collector) Tail(n int) string { return tail(c.Output(), n) }

// WaitFor polls the collector output for substr.
func (c *Collector) WaitFor(substr string, timeout time.Duration) bool {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if strings.Contains(c.Output(), substr) {
			return true
		}
		time.Sleep(50 * time.Millisecond)
	}
	return false
}

// SendSpans exports the spans fn creates to the collector over OTLP/HTTP and flushes them.
func (c *Collector) SendSpans(t testing.TB, service string, fn func(ctx context.Context, tr trace.Tracer)) {
	t.Helper()
	ctx := context.Background()
	exp, err := otlptracehttp.New(ctx, otlptracehttp.WithEndpointURL(c.Endpoint+"/v1/traces"))
	if err != nil {
		t.Fatal(err)
	}
	res := resource.NewSchemaless(resource.Default().Attributes()...)
	res, _ = resource.Merge(res, resource.NewSchemaless(attribute.String("service.name", service)))
	tp := sdktrace.NewTracerProvider(sdktrace.WithSyncer(exp), sdktrace.WithResource(res))
	fn(ctx, tp.Tracer("otellings/check"))
	if err := tp.Shutdown(ctx); err != nil {
		t.Fatalf("sending spans to the collector at %s: %v\ncollector log:\n%s", c.Endpoint, err, tail(c.Output(), 20))
	}
}

func tail(s string, n int) string {
	lines := strings.Split(strings.TrimRight(s, "\n"), "\n")
	if len(lines) > n {
		lines = lines[len(lines)-n:]
	}
	return strings.Join(lines, "\n")
}
