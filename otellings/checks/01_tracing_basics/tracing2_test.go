//go:build otellings_check

/* HINT
Call tp.Shutdown(ctx) before returning. A deferred call is the usual way,
and a named return value lets the defer report Shutdown's error:

  func Run(...) (err error) {
      ...
      defer func() { err = errors.Join(err, tp.Shutdown(ctx)) }()
*/

package tracing2

import (
	"context"
	"errors"
	"slices"
	"sync"
	"testing"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/sdk/trace/tracetest"
)

// keeper remembers exported spans; InMemoryExporter forgets them on Shutdown.
type keeper struct {
	mu    sync.Mutex
	names []string
}

func (k *keeper) ExportSpans(_ context.Context, spans []sdktrace.ReadOnlySpan) error {
	k.mu.Lock()
	defer k.mu.Unlock()
	for _, s := range spans {
		k.names = append(k.names, s.Name())
	}
	return nil
}

func (k *keeper) Shutdown(context.Context) error { return nil }

func TestRunFlushes(t *testing.T) {
	exp := &keeper{}
	if err := Run(t.Context(), exp); err != nil {
		t.Fatalf("Run: %v", err)
	}
	exp.mu.Lock()
	names := slices.Clone(exp.names)
	exp.mu.Unlock()
	if !slices.Equal(names, []string{"download", "transform", "upload"}) {
		t.Fatalf("exporter received %q right after Run returned, want [download transform upload]", names)
	}
}

type failingShutdown struct{ *tracetest.InMemoryExporter }

func (failingShutdown) Shutdown(context.Context) error { return errors.New("exporter could not flush") }

var _ sdktrace.SpanExporter = failingShutdown{}

func TestRunReportsShutdownError(t *testing.T) {
	err := Run(t.Context(), failingShutdown{tracetest.NewInMemoryExporter()})
	if err == nil {
		t.Fatal("the exporter failed to shut down but Run returned nil")
	}
}
