//go:build otellings_check

/* HINT
Change the field type to metric.Int64UpDownCounter and create it with
m.Int64UpDownCounter(...). Acquire and Release can stay as they are.
*/

package metrics3

import (
	"testing"

	"otellings/checks/checkutil"

	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

func TestUpDown(t *testing.T) {
	r := sdkmetric.NewManualReader()
	mp := sdkmetric.NewMeterProvider(sdkmetric.WithReader(r))
	p, err := NewPool(mp.Meter("check"))
	if err != nil {
		t.Fatal(err)
	}
	ctx := t.Context()
	p.Acquire(ctx)
	p.Acquire(ctx)
	p.Acquire(ctx)
	p.Release(ctx)
	m := checkutil.Metric(t, checkutil.Collect(t, r), "db.client.connection.count")
	sum := m.Data.(metricdata.Sum[int64])
	if sum.IsMonotonic {
		t.Errorf("the connection count is monotonic; it must be able to go down")
	}
	if len(sum.DataPoints) != 1 || sum.DataPoints[0].Value != 2 {
		t.Errorf("after 3 acquires and 1 release the value is %+v, want 2", sum.DataPoints)
	}
}
