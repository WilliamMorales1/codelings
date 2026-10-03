// status1 -- recording errors
//
// A span has a status: Unset (the default), Error or Ok. Backends use it to
// color traces red and compute error rates. Recording an error takes two
// separate calls, and people routinely make only one:
//
//   span.RecordError(err)                     // adds an "exception" event with
//                                             // exception.type / exception.message
//   span.SetStatus(codes.Error, err.Error())  // marks the span as failed
//
// RecordError alone leaves the span looking healthy. Leave successful spans
// Unset: Ok is meant for someone overriding an error decision.
//
// Task: Charge stuffs the error into a made-up attribute. Record it properly
// and mark the span as failed, with the error text as the description.
//

package status1

import (
	"context"
	"fmt"

	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

// Charge takes money from a card.
func Charge(ctx context.Context, tr trace.Tracer, cents int) error {
	_, span := tr.Start(ctx, "charge")
	defer span.End()

	if cents <= 0 {
		err := fmt.Errorf("invalid amount %d", cents)
		span.RecordError(err)
		span.SetStatus(codes.Error, err.Error())
		return err
	}
	return nil
}
