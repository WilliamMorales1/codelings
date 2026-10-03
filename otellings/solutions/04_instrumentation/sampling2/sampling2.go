// sampling2 -- respect your parent's decision
//
// A bare TraceIDRatioBased sampler decides on its own for every span, even
// when a remote caller already decided (the sampled flag, the last byte of
// traceparent). If the caller used a different ratio or a different
// sampler, the two services disagree and you get traces with holes.
//
// ParentBased(root) delegates only *root* spans to root; for everything
// with a parent it follows the parent's sampled flag (configurable per
// remote/local and sampled/unsampled, but those are the defaults).
//
// Task: keep sampling 10% of new traces, but always follow the parent's
// decision when there is one.
//

package sampling2

import (
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// NewProvider builds the service's TracerProvider.
func NewProvider(sp sdktrace.SpanProcessor) *sdktrace.TracerProvider {
	return sdktrace.NewTracerProvider(
		sdktrace.WithSpanProcessor(sp),
		sdktrace.WithSampler(sdktrace.ParentBased(sdktrace.TraceIDRatioBased(0.1))),
	)
}
