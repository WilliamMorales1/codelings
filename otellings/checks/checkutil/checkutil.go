// Package checkutil holds the helpers shared by the hidden exercise checks.
package checkutil

import (
	"context"
	"fmt"
	"slices"
	"strings"
	"sync"
	"testing"

	"go.opentelemetry.io/otel/attribute"
	sdklog "go.opentelemetry.io/otel/sdk/log"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/sdk/trace/tracetest"
)

// Tracing returns a span recorder and a TracerProvider that feeds it synchronously.
func Tracing(t testing.TB, opts ...sdktrace.TracerProviderOption) (*tracetest.SpanRecorder, *sdktrace.TracerProvider) {
	t.Helper()
	sr := tracetest.NewSpanRecorder()
	tp := sdktrace.NewTracerProvider(append([]sdktrace.TracerProviderOption{sdktrace.WithSpanProcessor(sr)}, opts...)...)
	t.Cleanup(func() { tp.Shutdown(context.Background()) })
	return sr, tp
}

// Attr looks up key in kvs.
func Attr(kvs []attribute.KeyValue, key string) (attribute.Value, bool) {
	for _, kv := range kvs {
		if string(kv.Key) == key {
			return kv.Value, true
		}
	}
	return attribute.Value{}, false
}

// Names lists span names, for error messages.
func Names(spans []sdktrace.ReadOnlySpan) []string {
	out := make([]string, 0, len(spans))
	for _, s := range spans {
		out = append(out, fmt.Sprintf("%q", s.Name()))
	}
	return out
}

// Span returns the one ended span called name, failing the test otherwise.
func Span(t testing.TB, spans []sdktrace.ReadOnlySpan, name string) sdktrace.ReadOnlySpan {
	t.Helper()
	var found []sdktrace.ReadOnlySpan
	for _, s := range spans {
		if s.Name() == name {
			found = append(found, s)
		}
	}
	switch len(found) {
	case 0:
		t.Fatalf("no ended span named %q; ended spans: [%s]", name, strings.Join(Names(spans), ", "))
	case 1:
	default:
		t.Fatalf("expected one span named %q, got %d", name, len(found))
	}
	return found[0]
}

// Collect gathers everything the reader has seen so far.
func Collect(t testing.TB, r sdkmetric.Reader) metricdata.ResourceMetrics {
	t.Helper()
	var rm metricdata.ResourceMetrics
	if err := r.Collect(context.Background(), &rm); err != nil {
		t.Fatalf("collecting metrics: %v", err)
	}
	return rm
}

// Metric finds a metric by name in rm, failing the test when it is absent.
func Metric(t testing.TB, rm metricdata.ResourceMetrics, name string) metricdata.Metrics {
	t.Helper()
	var names []string
	for _, sm := range rm.ScopeMetrics {
		for _, m := range sm.Metrics {
			if m.Name == name {
				return m
			}
			names = append(names, fmt.Sprintf("%q", m.Name))
		}
	}
	t.Fatalf("no metric named %q; collected: [%s]", name, strings.Join(names, ", "))
	return metricdata.Metrics{}
}

// LogRecorder is an sdklog.Processor that keeps every emitted record in memory.
type LogRecorder struct {
	mu      sync.Mutex
	records []sdklog.Record
}

func (r *LogRecorder) Enabled(context.Context, sdklog.EnabledParameters) bool { return true }

func (r *LogRecorder) OnEmit(_ context.Context, rec *sdklog.Record) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.records = append(r.records, rec.Clone())
	return nil
}

func (r *LogRecorder) Shutdown(context.Context) error   { return nil }
func (r *LogRecorder) ForceFlush(context.Context) error { return nil }

// Records returns a copy of what has been emitted so far.
func (r *LogRecorder) Records() []sdklog.Record {
	r.mu.Lock()
	defer r.mu.Unlock()
	return slices.Clone(r.records)
}

// LogAttrs flattens a record's attributes.
func LogAttrs(rec sdklog.Record) []attribute.KeyValue {
	var out []attribute.KeyValue
	rec.WalkAttributes(func(kv attribute.KeyValue) bool {
		out = append(out, kv)
		return true
	})
	return out
}
