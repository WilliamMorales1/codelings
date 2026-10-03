// metrics3 -- up-down counters
//
// A Counter must never decrease: the SDK drops negative increments (and
// logs a warning), because backends compute rates from counters and a
// decrease would look like a reset.
//
// Things that go up *and* down, like open connections, queue length or
// in-flight requests, use an UpDownCounter. Its sum is non-monotonic, so
// backends graph it as a current value instead of a rate.
//
// Task: the connection pool counts open connections with a Counter, so
// Release has no effect. Use an Int64UpDownCounter instead.
//

package metrics3

import (
	"context"

	"go.opentelemetry.io/otel/metric"
)

type Pool struct {
	open metric.Int64Counter
}

// NewPool creates the pool's instruments.
func NewPool(m metric.Meter) (*Pool, error) {
	open, err := m.Int64Counter("db.client.connection.count",
		metric.WithUnit("{connection}"),
		metric.WithDescription("Connections currently open."),
	)
	return &Pool{open: open}, err
}

func (p *Pool) Acquire(ctx context.Context) { p.open.Add(ctx, 1) }
func (p *Pool) Release(ctx context.Context) { p.open.Add(ctx, -1) }
