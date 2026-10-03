//go:build otellings_check

/* HINT
The second argument of Start is the span name. Make it "hello".
*/

package intro1

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel"
)

func TestHello(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	otel.SetTracerProvider(tp)

	if got := Hello(t.Context()); got != "hello, telemetry" {
		t.Errorf("Hello returned %q", got)
	}
	span := checkutil.Span(t, sr.Ended(), "hello")
	if got := span.InstrumentationScope().Name; got != "otellings/intro1" {
		t.Errorf("scope name = %q, want otellings/intro1", got)
	}
}
