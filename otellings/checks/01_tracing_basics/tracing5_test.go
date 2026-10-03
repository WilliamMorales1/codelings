//go:build otellings_check

/* HINT
tr.Start returns (context.Context, trace.Span). Keep the context:

  ctx, span := tr.Start(ctx, "checkout")

and hand that ctx to the steps.
*/

package tracing5

import (
	"testing"

	"otellings/checks/checkutil"
)

func TestChildrenShareTheTrace(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	Checkout(t.Context(), tp.Tracer("check"))
	spans := sr.Ended()
	root := checkutil.Span(t, spans, "checkout")
	if root.Parent().IsValid() {
		t.Errorf("checkout should be a root span")
	}
	for _, name := range []string{"reserve-stock", "charge-card"} {
		s := checkutil.Span(t, spans, name)
		if s.SpanContext().TraceID() != root.SpanContext().TraceID() {
			t.Errorf("%s is in a different trace than checkout", name)
		}
		if s.Parent().SpanID() != root.SpanContext().SpanID() {
			t.Errorf("%s's parent is not the checkout span", name)
		}
	}
}
