//go:build otellings_check

/* HINT
  return otlptracehttp.New(ctx)

An http:// endpoint in OTEL_EXPORTER_OTLP_ENDPOINT already implies an
insecure (plain HTTP) connection.
*/

package setup3

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

func TestEnvConfiguredExporter(t *testing.T) {
	type hit struct{ path, key, ctype string }
	hits := make(chan hit, 10)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hits <- hit{r.URL.Path, r.Header.Get("x-api-key"), r.Header.Get("Content-Type")}
		w.Header().Set("Content-Type", "application/x-protobuf")
	}))
	defer srv.Close()
	t.Setenv("OTEL_EXPORTER_OTLP_ENDPOINT", srv.URL)
	t.Setenv("OTEL_EXPORTER_OTLP_HEADERS", "x-api-key=s3cret")
	t.Setenv("OTEL_EXPORTER_OTLP_TIMEOUT", "2000")

	exp, err := NewExporter(t.Context())
	if err != nil {
		t.Fatal(err)
	}
	tp := sdktrace.NewTracerProvider(sdktrace.WithSyncer(exp))
	_, span := tp.Tracer("check").Start(t.Context(), "job")
	span.End()
	ctx, cancel := context.WithTimeout(t.Context(), 3*time.Second)
	defer cancel()
	tp.Shutdown(ctx)

	select {
	case h := <-hits:
		if h.path != "/v1/traces" {
			t.Errorf("exporter posted to %s, want /v1/traces", h.path)
		}
		if h.key != "s3cret" {
			t.Errorf("x-api-key header = %q; OTEL_EXPORTER_OTLP_HEADERS was ignored", h.key)
		}
		if h.ctype != "application/x-protobuf" {
			t.Errorf("content type = %q, want protobuf", h.ctype)
		}
	default:
		t.Fatalf("nothing reached OTEL_EXPORTER_OTLP_ENDPOINT (%s): options in code override the environment", srv.URL)
	}
}
