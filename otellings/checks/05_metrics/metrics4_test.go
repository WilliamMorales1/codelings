//go:build otellings_check

/* HINT
  metric.WithUnit("s"),
  metric.WithExplicitBucketBoundaries(0.005, 0.01, ...),

and record d.Seconds(), which is already a float64.
*/

package metrics4

import (
	"math"
	"slices"
	"testing"
	"time"

	"otellings/checks/checkutil"

	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

func TestHistogram(t *testing.T) {
	r := sdkmetric.NewManualReader()
	mp := sdkmetric.NewMeterProvider(sdkmetric.WithReader(r))
	x, err := New(mp.Meter("check"))
	if err != nil {
		t.Fatal(err)
	}
	x.Observe(t.Context(), 30*time.Millisecond)
	x.Observe(t.Context(), 1500*time.Millisecond)

	m := checkutil.Metric(t, checkutil.Collect(t, r), "http.server.request.duration")
	if m.Unit != "s" {
		t.Errorf("unit = %q, want s", m.Unit)
	}
	h := m.Data.(metricdata.Histogram[float64])
	dp := h.DataPoints[0]
	want := []float64{0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1, 2.5, 5, 7.5, 10}
	if !slices.Equal(dp.Bounds, want) {
		t.Fatalf("bucket boundaries = %v, want %v", dp.Bounds, want)
	}
	if math.Abs(dp.Sum-1.53) > 1e-9 {
		t.Errorf("sum = %v, want 1.53 (seconds)", dp.Sum)
	}
	// 0.03s falls in (0.025, 0.05], which is bucket index 3.
	if dp.BucketCounts[3] != 1 {
		t.Errorf("the 30ms request is not in the (0.025, 0.05] bucket: %v", dp.BucketCounts)
	}
}
