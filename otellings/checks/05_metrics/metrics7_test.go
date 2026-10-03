//go:build otellings_check

/* HINT
Just remove the user.id attribute from the Add call. If you want the user
on the telemetry, put it on the request's span instead.
*/

package metrics7

import (
	"fmt"
	"testing"

	"otellings/checks/checkutil"

	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

func TestBoundedSeries(t *testing.T) {
	r := sdkmetric.NewManualReader()
	mp := sdkmetric.NewMeterProvider(sdkmetric.WithReader(r))
	x, err := New(mp.Meter("check"))
	if err != nil {
		t.Fatal(err)
	}
	for i := range 500 {
		route := []string{"/books/{id}", "/cart"}[i%2]
		status := []int{200, 200, 200, 404}[i%4]
		x.Request(t.Context(), fmt.Sprintf("u%d", i), route, status)
	}
	sum := checkutil.Metric(t, checkutil.Collect(t, r), "http.server.requests").Data.(metricdata.Sum[int64])
	if n := len(sum.DataPoints); n > 4 {
		t.Fatalf("500 requests produced %d series; route x status should give at most 4", n)
	}
	var total int64
	for _, dp := range sum.DataPoints {
		if _, ok := dp.Attributes.Value("http.route"); !ok {
			t.Errorf("keep http.route")
		}
		if _, ok := dp.Attributes.Value("http.response.status_code"); !ok {
			t.Errorf("keep http.response.status_code")
		}
		total += dp.Value
	}
	if total != 500 {
		t.Errorf("counted %d requests, want 500", total)
	}
}
