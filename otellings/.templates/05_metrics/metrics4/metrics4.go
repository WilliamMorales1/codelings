// metrics4 -- histograms, units and buckets
//
// A Histogram records a distribution: count, sum, min/max and counts per
// bucket, from which backends estimate percentiles. Two details matter:
//
//   - unit: the semantic conventions measure durations in *seconds* ("s"),
//     as float64. Mixing ms and s between services breaks every dashboard.
//   - buckets: the SDK's default boundaries (0, 5, 10, 25, 50, 75, 100, 250,
//     ... 10000) were made for milliseconds. In seconds, every request
//     under 5s would land in one bucket. Instruments can *advise* better
//     boundaries with metric.WithExplicitBucketBoundaries.
//
// Task: record http.server.request.duration in seconds with unit "s" and
// the boundaries recommended by the HTTP semantic conventions:
//   0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1, 2.5, 5, 7.5, 10
//

package metrics4

import (
	"context"
	"time"

	"go.opentelemetry.io/otel/metric"
)

type Metrics struct {
	duration metric.Float64Histogram
}

func New(m metric.Meter) (*Metrics, error) {
	d, err := m.Float64Histogram("http.server.request.duration",
		metric.WithUnit("ms"),
		metric.WithDescription("Duration of HTTP server requests."),
	)
	return &Metrics{duration: d}, err
}

// Observe records how long one request took.
func (x *Metrics) Observe(ctx context.Context, d time.Duration) {
	x.duration.Record(ctx, float64(d.Milliseconds()))
}
