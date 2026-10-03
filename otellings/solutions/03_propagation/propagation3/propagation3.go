// propagation3 -- the global propagator
//
// Instrumentation libraries (otelhttp, otelgrpc, ...) do not hard-code a
// format: they call otel.GetTextMapPropagator(). Out of the box that is a
// *no-op* propagator, so nothing is injected until the application picks
// one at startup, next to installing the TracerProvider.
//
// Most apps want two: TraceContext for traceparent/tracestate, and Baggage
// for the `baggage` header (key/value pairs that ride along with the trace;
// see the next exercise). A composite propagator runs several in turn.
//
// Task: Setup installs only TraceContext, so baggage never leaves the
// process. Install a composite of TraceContext and Baggage.
//

package propagation3

import (
	"net/http"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/propagation"
)

// Setup configures context propagation for the whole program.
func Setup() {
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))
}

// Outgoing is what any instrumented client does with a request.
func Outgoing(req *http.Request) {
	otel.GetTextMapPropagator().Inject(req.Context(), propagation.HeaderCarrier(req.Header))
}
