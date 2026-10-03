// tracing6 -- enriching the span you are already in
//
// Not every function deserves its own span. A helper that only learns
// something interesting (who the user is, which cache tier answered) should
// add that to the span its caller already started.
// trace.SpanFromContext(ctx) returns that span (or a no-op span if there is
// none, so it is always safe to call).
//
// Task: tagUser creates a whole extra span just to hold one attribute.
// Make it set "user.id" on the current span instead, so a request produces
// exactly one span: "handle", carrying user.id.
//

package tracing6

import (
	"context"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

// Handle serves one request.
func Handle(ctx context.Context, tr trace.Tracer, user string) {
	ctx, span := tr.Start(ctx, "handle")
	defer span.End()
	tagUser(ctx, user)
}

func tagUser(ctx context.Context, user string) {
	trace.SpanFromContext(ctx).SetAttributes(attribute.String("user.id", user))
}
