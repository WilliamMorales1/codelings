//go:build otellings_check

/* HINT
  propagation.TraceContext{}.Inject(ctx, propagation.HeaderCarrier(req.Header))

propagation is go.opentelemetry.io/otel/propagation.
*/

package propagation1

import (
	"fmt"
	"testing"

	"otellings/checks/checkutil"
)

func TestTraceparent(t *testing.T) {
	_, tp := checkutil.Tracing(t)
	ctx, span := tp.Tracer("check").Start(t.Context(), "caller")
	defer span.End()
	req, err := NewRequest(ctx, "http://inventory.internal/items")
	if err != nil {
		t.Fatal(err)
	}
	if req.Header.Get("X-Trace-Id") != "" {
		t.Errorf("drop the home-made X-Trace-Id header")
	}
	sc := span.SpanContext()
	want := fmt.Sprintf("00-%s-%s-01", sc.TraceID(), sc.SpanID())
	if got := req.Header.Get("traceparent"); got != want {
		t.Errorf("traceparent = %q, want %q", got, want)
	}
}
