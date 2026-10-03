//go:build otellings_check

/* HINT
  trace.SpanFromContext(ctx).SetAttributes(attribute.String("user.id", user))

and delete the Start/End pair (and the now unused otel import).
*/

package tracing6

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel"
)

func TestOneSpanWithUser(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	otel.SetTracerProvider(tp)
	Handle(t.Context(), tp.Tracer("check"), "ada")
	spans := sr.Ended()
	if len(spans) != 1 {
		t.Fatalf("got spans %v, want only \"handle\"", checkutil.Names(spans))
	}
	v, ok := checkutil.Attr(spans[0].Attributes(), "user.id")
	if !ok || v.AsString() != "ada" {
		t.Errorf("handle span has no user.id=ada attribute")
	}
}
