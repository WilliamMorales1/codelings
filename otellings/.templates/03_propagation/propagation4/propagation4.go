// propagation4 -- baggage
//
// Baggage is a set of key/value pairs that travels with the request across
// every service hop (the `baggage` header), independent of spans. Typical
// use: a tenant id or feature flag set at the edge that every service
// downstream wants to know about. It is *not* automatically added to spans;
// services copy what they need into attributes.
//
// It is also sent to every downstream service, including third parties:
// never put secrets or personal data in baggage.
//
// Task: WithTenant hides the tenant in a private context key that no
// propagator knows about. Store it as the baggage member "tenant.id"
// instead, and make TagSpan read it from baggage and set it as the
// "tenant.id" span attribute.
//

package propagation4

import (
	"context"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

type tenantKey struct{}

// WithTenant marks everything done with the returned context as belonging to tenant.
func WithTenant(ctx context.Context, tenant string) (context.Context, error) {
	return context.WithValue(ctx, tenantKey{}, tenant), nil
}

// TagSpan copies the tenant onto the current span, on the receiving service.
func TagSpan(ctx context.Context) {
	tenant, _ := ctx.Value(tenantKey{}).(string)
	trace.SpanFromContext(ctx).SetAttributes(attribute.String("tenant.id", tenant))
}
