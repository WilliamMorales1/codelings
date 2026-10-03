//go:build otellings_check

/* HINT
Move the q.Len() call inside the callback:

  o.Observe(int64(q.Len()))
*/

package metrics6

import (
	"testing"

	"otellings/checks/checkutil"

	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

func TestGaugeFollowsQueue(t *testing.T) {
	r := sdkmetric.NewManualReader()
	mp := sdkmetric.NewMeterProvider(sdkmetric.WithReader(r))
	q := &Queue{}
	if err := Register(mp.Meter("check"), q); err != nil {
		t.Fatal(err)
	}
	for _, want := range []int64{0, 3, 5} {
		for q.Len() < int(want) {
			q.Push("job")
		}
		g := checkutil.Metric(t, checkutil.Collect(t, r), "queue.depth").Data.(metricdata.Gauge[int64])
		if len(g.DataPoints) != 1 || g.DataPoints[0].Value != want {
			t.Errorf("queue.depth = %+v with %d items queued", g.DataPoints, want)
		}
	}
}
