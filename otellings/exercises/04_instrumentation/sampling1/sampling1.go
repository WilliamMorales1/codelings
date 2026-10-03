// sampling1 -- head sampling by trace ID
//
// Tracing every request is expensive at scale. A *sampler* decides, when a
// root span starts, whether this trace is recorded and exported. The
// default is ParentBased(AlwaysSample()): keep everything.
//
// TraceIDRatioBased(f) keeps a fraction f of traces. The decision is a pure
// function of the trace ID, so every service that uses the same ratio makes
// the same call for the same trace, without talking to each other.
//
// Unsampled spans still exist (they carry context along) but are
// non-recording: attributes are dropped and processors never see them.
//
// Task: the service should keep about 10% of traces. Configure the
// provider's sampler accordingly.
//

package sampling1

import (
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// NewProvider builds the service's TracerProvider.
func NewProvider(sp sdktrace.SpanProcessor) *sdktrace.TracerProvider {
	return sdktrace.NewTracerProvider(
		sdktrace.WithSpanProcessor(sp),
	)
}
