// links1 -- links instead of parents
//
// A span has at most one parent. But a batch job that processes 50 queued
// messages is caused by 50 different traces. Picking one of them as parent
// (as below) glues the batch onto a random request's trace and hides the
// relation to the other 49.
//
// A *link* is a reference to another span context that is not a parent.
// Links are passed at start time with trace.WithLinks(trace.Link{...}).
//
// Task: make "process batch" a fresh root span with one link to every
// message's span context.
//

package links1

import (
	"context"

	"go.opentelemetry.io/otel/trace"
)

// Message carries the span context of whoever enqueued it.
type Message struct {
	Body   string
	Origin trace.SpanContext
}

// ProcessBatch handles a batch of messages in one go.
func ProcessBatch(ctx context.Context, tr trace.Tracer, batch []Message) {
	links := make([]trace.Link, 0, len(batch))
	for _, m := range batch {
		links = append(links, trace.Link{SpanContext: m.Origin})
	}
	_, span := tr.Start(ctx, "process batch",
		trace.WithSpanKind(trace.SpanKindConsumer),
		trace.WithLinks(links...),
		trace.WithNewRoot(),
	)
	defer span.End()
}
