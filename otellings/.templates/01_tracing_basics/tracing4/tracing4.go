// tracing4 -- span names are for grouping
//
// Backends group, count and time spans by *name*. A name must describe the
// kind of operation, not one particular call: "GET /users/{id}" is a good
// name, "GET /users/8412" is a new name for every user and ruins every
// latency graph (this is called high cardinality).
//
// Per-call details belong in attributes, which are made for exactly that.
//
// Task: give the span a stable name, "GET /users/{id}", and move the user id
// into a "user.id" string attribute. Pass it when starting the span with
// trace.WithAttributes, so samplers can see it too.
//

package tracing4

import (
	"context"

	"go.opentelemetry.io/otel/trace"
)

// GetUser pretends to load a user.
func GetUser(ctx context.Context, tr trace.Tracer, id string) {
	_, span := tr.Start(ctx, "GET /users/"+id)
	defer span.End()
}
