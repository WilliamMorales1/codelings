// propagation2 -- extracting on the server
//
// The receiving side reads traceparent back into a context ("extract") and
// starts its server span from that context. The extracted span context is
// *remote*: it lives in another process, but it still becomes the parent,
// so both services' spans land in one trace.
//
// Task: the inventory handler starts every request as a brand-new trace.
// Extract the incoming W3C trace context from r.Header first.
//

package propagation2

import (
	"fmt"
	"net/http"

	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/trace"
)

// Handler serves GET /items.
func Handler(tr trace.Tracer) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := propagation.TraceContext{}.Extract(r.Context(), propagation.HeaderCarrier(r.Header))
		_, span := tr.Start(ctx, "GET /items", trace.WithSpanKind(trace.SpanKindServer))
		defer span.End()
		fmt.Fprintln(w, "3 teapots")
	})
}
