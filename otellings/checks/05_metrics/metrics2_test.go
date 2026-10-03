//go:build otellings_check

/* HINT
m.Int64Counter("orders.placed", metric.WithUnit("{order}"), metric.WithDescription("..."))

x.orders.Add(ctx, 1, metric.WithAttributes(attribute.String("payment.method", method)))
*/

package metrics2

import (
	"testing"

	"otellings/checks/checkutil"

	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

func TestCounter(t *testing.T) {
	r := sdkmetric.NewManualReader()
	mp := sdkmetric.NewMeterProvider(sdkmetric.WithReader(r))
	x, err := New(mp.Meter("check"))
	if err != nil {
		t.Fatal(err)
	}
	for _, m := range []string{"card", "paypal", "card"} {
		x.OrderPlaced(t.Context(), m)
	}
	m := checkutil.Metric(t, checkutil.Collect(t, r), "orders.placed")
	if m.Unit != "{order}" {
		t.Errorf("unit = %q, want {order}", m.Unit)
	}
	if m.Description == "" {
		t.Errorf("give the counter a description")
	}
	sum := m.Data.(metricdata.Sum[int64])
	if !sum.IsMonotonic {
		t.Errorf("orders.placed should be a monotonic counter")
	}
	got := map[string]int64{}
	for _, dp := range sum.DataPoints {
		v, _ := dp.Attributes.Value("payment.method")
		got[v.AsString()] = dp.Value
	}
	if len(got) != 2 || got["card"] != 2 || got["paypal"] != 1 {
		t.Errorf("series by payment.method = %v, want map[card:2 paypal:1]", got)
	}
}
