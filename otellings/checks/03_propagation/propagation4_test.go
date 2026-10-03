//go:build otellings_check

/* HINT
  m, err := baggage.NewMember("tenant.id", tenant)
  b, err := baggage.FromContext(ctx).SetMember(m)   // keeps existing members
  return baggage.ContextWithBaggage(ctx, b), nil

and on the reading side:

  baggage.FromContext(ctx).Member("tenant.id").Value()
*/

package propagation4

import (
	"net/http"
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/baggage"
	"go.opentelemetry.io/otel/propagation"
)

func TestBaggageCrossesTheWire(t *testing.T) {
	m, _ := baggage.NewMember("region", "eu")
	b, _ := baggage.New(m)
	ctx := baggage.ContextWithBaggage(t.Context(), b)

	ctx, err := WithTenant(ctx, "acme")
	if err != nil {
		t.Fatal(err)
	}
	h := http.Header{}
	propagation.Baggage{}.Inject(ctx, propagation.HeaderCarrier(h))
	got, _ := baggage.Parse(h.Get("baggage"))
	if got.Member("tenant.id").Value() != "acme" {
		t.Fatalf("baggage header %q has no tenant.id=acme", h.Get("baggage"))
	}
	if got.Member("region").Value() != "eu" {
		t.Errorf("WithTenant dropped the existing region=eu member")
	}

	// The other service: extract, start a span, tag it.
	sr, tp := checkutil.Tracing(t)
	remote := propagation.Baggage{}.Extract(t.Context(), propagation.HeaderCarrier(h))
	remote, span := tp.Tracer("check").Start(remote, "server")
	TagSpan(remote)
	span.End()
	if v, _ := checkutil.Attr(sr.Ended()[0].Attributes(), "tenant.id"); v.AsString() != "acme" {
		t.Errorf("server span tenant.id = %q, want acme", v.AsString())
	}
}
