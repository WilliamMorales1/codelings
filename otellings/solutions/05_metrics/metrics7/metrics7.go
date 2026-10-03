// metrics7 -- attribute cardinality
//
// Every distinct combination of attribute values is its own time series,
// kept in memory by the SDK and billed by your backend. Attributes on
// metrics must come from a small, bounded set: route templates, status
// codes, methods. IDs (user, request, order), raw URLs, and error messages
// explode the series count; they belong on spans and logs, not metrics.
//
// Task: Request labels the counter with the user id, so 10,000 users mean
// 10,000+ series. Keep http.route and http.response.status_code, drop the
// user id.
//

package metrics7

import (
	"context"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

type Metrics struct {
	requests metric.Int64Counter
}

func New(m metric.Meter) (*Metrics, error) {
	c, err := m.Int64Counter("http.server.requests", metric.WithUnit("{request}"))
	return &Metrics{requests: c}, err
}

// Request counts one finished request.
func (x *Metrics) Request(ctx context.Context, userID, route string, status int) {
	x.requests.Add(ctx, 1, metric.WithAttributes(

		attribute.String("http.route", route),
		attribute.Int("http.response.status_code", status),
	))
}
