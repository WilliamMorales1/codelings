// propagation1 -- injecting traceparent
//
// A trace crosses process boundaries only if the caller *tells* the callee
// which trace it is in. The W3C Trace Context standard does this with one
// HTTP header:
//
//   traceparent: 00-<32 hex trace id>-<16 hex parent span id>-<2 hex flags>
//
// In OpenTelemetry a TextMapPropagator writes ("injects") the span context
// from a context.Context into a carrier, and reads ("extracts") it on the
// other side. propagation.HeaderCarrier adapts http.Header to a carrier.
//
// Task: NewRequest invents its own X-Trace-Id header, which no other service
// understands. Inject the span context from ctx into the request headers with
// propagation.TraceContext{} instead.
//

package propagation1

import (
	"context"
	"net/http"

	"go.opentelemetry.io/otel/propagation"
)

// NewRequest builds a GET request that continues the trace in ctx.
func NewRequest(ctx context.Context, url string) (*http.Request, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	propagation.TraceContext{}.Inject(ctx, propagation.HeaderCarrier(req.Header))
	return req, nil
}
