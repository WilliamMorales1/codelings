// tracing5 -- parents travel in the context
//
// There is no global "current span" in Go. Start(ctx, ...) returns a new
// context that carries the new span, and whatever span is in the context
// passed to the *next* Start becomes that span's parent. Forget to use the
// returned context and every child becomes the root of its own trace.
//
// Task: Checkout's two steps should appear as children of the "checkout"
// span in one trace. Right now they start three separate traces.
//

package tracing5

import (
	"context"

	"go.opentelemetry.io/otel/trace"
)

// Checkout reserves stock and charges the card.
func Checkout(ctx context.Context, tr trace.Tracer) {
	_, span := tr.Start(ctx, "checkout")
	defer span.End()

	reserveStock(ctx, tr)
	chargeCard(ctx, tr)
}

func reserveStock(ctx context.Context, tr trace.Tracer) {
	_, span := tr.Start(ctx, "reserve-stock")
	defer span.End()
}

func chargeCard(ctx context.Context, tr trace.Tracer) {
	_, span := tr.Start(ctx, "charge-card")
	defer span.End()
}
