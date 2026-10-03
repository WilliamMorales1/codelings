//go:build otellings_check

/* HINT
otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
    propagation.TraceContext{},
    propagation.Baggage{},
))
*/

package propagation3

import (
	"net/http/httptest"
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/baggage"
)

func TestCompositePropagator(t *testing.T) {
	Setup()
	_, tp := checkutil.Tracing(t)
	ctx, span := tp.Tracer("check").Start(t.Context(), "caller")
	defer span.End()
	m, _ := baggage.NewMember("tenant.id", "acme")
	b, _ := baggage.New(m)
	ctx = baggage.ContextWithBaggage(ctx, b)

	req := httptest.NewRequest("GET", "/", nil).WithContext(ctx)
	Outgoing(req)
	if req.Header.Get("traceparent") == "" {
		t.Errorf("no traceparent header: TraceContext must stay in the mix")
	}
	if got := req.Header.Get("baggage"); got != "tenant.id=acme" {
		t.Errorf("baggage header = %q, want tenant.id=acme", got)
	}
}
