// propagation5 -- propagating through a message queue
//
// Propagators do not care about HTTP. A carrier is anything with Get/Set/Keys,
// and propagation.MapCarrier turns a map[string]string (message headers in
// Kafka, NATS, SQS attributes, ...) into one.
//
// Task: the producer should inject the trace context into msg.Headers and the
// consumer should extract it, so "receive" becomes a child of "send" even
// though they only share a channel. Use propagation.TraceContext{}.
//

package propagation5

import (
	"context"

	"go.opentelemetry.io/otel/trace"
)

type Message struct {
	Headers map[string]string
	Body    string
}

// Send publishes body on q.
func Send(ctx context.Context, tr trace.Tracer, q chan<- Message, body string) {
	_, span := tr.Start(ctx, "send", trace.WithSpanKind(trace.SpanKindProducer))
	defer span.End()
	msg := Message{Headers: map[string]string{}, Body: body}
	q <- msg
}

// Receive handles one message.
func Receive(ctx context.Context, tr trace.Tracer, msg Message) {
	_, span := tr.Start(ctx, "receive", trace.WithSpanKind(trace.SpanKindConsumer))
	defer span.End()
}
