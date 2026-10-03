//go:build otellings_check

/* HINT
tr.Start(ctx, "publish orders", trace.WithSpanKind(trace.SpanKindProducer))
*/

package kinds1

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/trace"
)

func TestKinds(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	tr := tp.Tracer("check")
	q := make(chan string, 1)
	Publish(t.Context(), tr, q, "order-1")
	Handle(t.Context(), tr, <-q)
	spans := sr.Ended()
	if k := checkutil.Span(t, spans, "publish orders").SpanKind(); k != trace.SpanKindProducer {
		t.Errorf("publish span kind = %s, want producer", k)
	}
	if k := checkutil.Span(t, spans, "process orders").SpanKind(); k != trace.SpanKindConsumer {
		t.Errorf("process span kind = %s, want consumer", k)
	}
}
