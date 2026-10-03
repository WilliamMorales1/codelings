// tracing3 -- every span must end
//
// A span is only exported once End is called. A span that never ends is
// simply lost, and in a trace UI its children float around without a
// parent. The classic cause is an early return that skips span.End().
//
// `defer span.End()` right after Start makes that impossible.
//
// Task: ProcessOrder has three ways out. Only one of them ends the span.
// Make every path end it.
//

package tracing3

import (
	"context"
	"errors"
	"strings"

	"go.opentelemetry.io/otel/trace"
)

// ProcessOrder validates and books an order.
func ProcessOrder(ctx context.Context, tr trace.Tracer, id string) error {
	ctx, span := tr.Start(ctx, "process-order")
	if id == "" {
		return errors.New("empty order id")
	}
	if err := validate(ctx, tr, id); err != nil {
		return err
	}
	span.End()
	return nil
}

func validate(ctx context.Context, tr trace.Tracer, id string) error {
	_, span := tr.Start(ctx, "validate")
	defer span.End()
	if !strings.HasPrefix(id, "ord-") {
		return errors.New("order ids start with ord-")
	}
	return nil
}
