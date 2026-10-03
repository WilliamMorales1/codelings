//go:build otellings_check

/* HINT
  sdktrace.WithBatcher(exp)

It has options too (WithBatchTimeout, WithMaxQueueSize,
WithMaxExportBatchSize), also settable via OTEL_BSP_* variables.
*/

package setup4

import (
	"context"
	"sync"
	"testing"
	"time"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// slowExporter takes 100ms per export call, like a distant collector.
type slowExporter struct {
	mu    sync.Mutex
	spans int
}

func (e *slowExporter) ExportSpans(_ context.Context, s []sdktrace.ReadOnlySpan) error {
	time.Sleep(100 * time.Millisecond)
	e.mu.Lock()
	e.spans += len(s)
	e.mu.Unlock()
	return nil
}

func (e *slowExporter) Shutdown(context.Context) error { return nil }

func TestEndDoesNotBlock(t *testing.T) {
	exp := &slowExporter{}
	tp := NewProvider(exp)
	tr := tp.Tracer("check")
	start := time.Now()
	for range 20 {
		_, s := tr.Start(t.Context(), "request")
		s.End()
	}
	if took := time.Since(start); took > 500*time.Millisecond {
		t.Errorf("ending 20 spans took %s: every End waits for the exporter", took.Round(time.Millisecond))
	}
	if err := tp.Shutdown(t.Context()); err != nil {
		t.Fatal(err)
	}
	if exp.spans != 20 {
		t.Errorf("exported %d spans after Shutdown, want 20", exp.spans)
	}
}
