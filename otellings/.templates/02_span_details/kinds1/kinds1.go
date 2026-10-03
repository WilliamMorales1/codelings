// kinds1 -- span kinds
//
// A span's kind says what role it plays in a conversation between services:
//
//   Server    handles an incoming synchronous request
//   Client    makes an outgoing synchronous request
//   Producer  hands a message to a broker/queue (and does not wait)
//   Consumer  processes a message it received
//   Internal  everything else (the default)
//
// Backends use kinds to draw service maps and to compute per-service
// latency. Everything below ends up Internal, so the queue in between
// vanishes from the service map.
//
// Task: start Publish's span as a Producer and Handle's as a Consumer, with
// trace.WithSpanKind.
//

package kinds1

import (
	"context"

	"go.opentelemetry.io/otel/trace"
)

// Publish sends body to the orders queue.
func Publish(ctx context.Context, tr trace.Tracer, queue chan<- string, body string) {
	_, span := tr.Start(ctx, "publish orders")
	defer span.End()
	queue <- body
}

// Handle processes one message from the orders queue.
func Handle(ctx context.Context, tr trace.Tracer, body string) {
	_, span := tr.Start(ctx, "process orders")
	defer span.End()
	_ = body
}
