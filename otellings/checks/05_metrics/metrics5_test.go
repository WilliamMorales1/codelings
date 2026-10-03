//go:build otellings_check

/* HINT
sdkmetric.WithView(
    sdkmetric.NewView(
        sdkmetric.Instrument{Name: "rpc.client.call.duration"},
        sdkmetric.Stream{Aggregation: sdkmetric.AggregationExplicitBucketHistogram{
            Boundaries: []float64{0.01, 0.1, 1, 10},
        }},
    ),
    sdkmetric.NewView(
        sdkmetric.Instrument{Name: "rpc.client.cache.lookups"},
        sdkmetric.Stream{AttributeFilter: attribute.NewAllowKeysFilter("cache.hit")},
    ),
)
*/

package metrics5

import (
	"fmt"
	"slices"
	"testing"
	"time"

	"otellings/checks/checkutil"

	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

func TestViews(t *testing.T) {
	r := sdkmetric.NewManualReader()
	c := NewClient(NewProvider(r))
	for i := range 50 {
		c.Call(t.Context(), "GetUser", 40*time.Millisecond, fmt.Sprintf("user:%d", i), i%5 != 0)
	}
	rm := checkutil.Collect(t, r)

	h := checkutil.Metric(t, rm, "rpc.client.call.duration").Data.(metricdata.Histogram[float64])
	if b := h.DataPoints[0].Bounds; !slices.Equal(b, []float64{0.01, 0.1, 1, 10}) {
		t.Errorf("duration buckets = %v, want [0.01 0.1 1 10]", b)
	}

	s := checkutil.Metric(t, rm, "rpc.client.cache.lookups").Data.(metricdata.Sum[int64])
	if len(s.DataPoints) != 2 {
		t.Fatalf("cache.lookups has %d series, want 2 (hit and miss)", len(s.DataPoints))
	}
	for _, dp := range s.DataPoints {
		if _, ok := dp.Attributes.Value("cache.key"); ok {
			t.Errorf("cache.key is still recorded")
		}
		hit, _ := dp.Attributes.Value("cache.hit")
		if want := map[bool]int64{true: 40, false: 10}[hit.AsBool()]; dp.Value != want {
			t.Errorf("cache.hit=%v count = %d, want %d", hit.AsBool(), dp.Value, want)
		}
	}
}
