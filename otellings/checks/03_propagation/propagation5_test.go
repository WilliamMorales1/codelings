//go:build otellings_check

/* HINT
Producer: keep the ctx that Start returns (it holds the "send" span), then

  propagation.TraceContext{}.Inject(ctx, propagation.MapCarrier(msg.Headers))

Consumer, before Start:

  ctx = propagation.TraceContext{}.Extract(ctx, propagation.MapCarrier(msg.Headers))
*/

package propagation5

import (
	"testing"

	"otellings/checks/checkutil"
)

func TestQueuePropagation(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	tr := tp.Tracer("check")
	q := make(chan Message, 1)
	Send(t.Context(), tr, q, "hello")
	msg := <-q
	if msg.Headers["traceparent"] == "" {
		t.Errorf("message headers carry no traceparent: %v", msg.Headers)
	}
	// The consumer runs with an unrelated context, as it would in another process.
	Receive(t.Context(), tr, msg)

	send := checkutil.Span(t, sr.Ended(), "send")
	recv := checkutil.Span(t, sr.Ended(), "receive")
	if recv.Parent().SpanID() != send.SpanContext().SpanID() {
		t.Errorf("receive's parent is not the send span")
	}
	if recv.SpanContext().TraceID() != send.SpanContext().TraceID() {
		t.Errorf("receive is in a different trace than send")
	}
}
