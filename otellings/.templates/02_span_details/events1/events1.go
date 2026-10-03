// events1 -- span events
//
// An event is a timestamped note inside a span: "cache miss", "retrying",
// "acquired lock". It is like a log line that is attached to exactly the
// operation it happened in, with its own attributes. (For things that
// deserve their own duration, use a child span instead.)
//
// Task: when the key is not cached, Lookup should add a "cache.miss" event
// with a "cache.key" attribute to its span, instead of the ad-hoc boolean
// attribute it sets now. A hit adds no event.
//

package events1

import (
	"context"
	"strings"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

// Lookup reads key through cache, filling it on a miss.
func Lookup(ctx context.Context, tr trace.Tracer, cache map[string]string, key string) string {
	_, span := tr.Start(ctx, "lookup")
	defer span.End()

	if v, ok := cache[key]; ok {
		return v
	}
	span.SetAttributes(attribute.Bool("cache.missed", true))
	v := strings.ToUpper(key) // the "slow" backend
	cache[key] = v
	return v
}
