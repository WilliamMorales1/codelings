//go:build otellings_check

/* HINT
  sdkmetric.NewMeterProvider(sdkmetric.WithReader(r))

In a real program r would be sdkmetric.NewPeriodicReader(exporter).
*/

package metrics1

import (
	"testing"

	"otellings/checks/checkutil"

	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

func TestReaderSeesLogins(t *testing.T) {
	r := sdkmetric.NewManualReader()
	shutdown := Setup(r)
	defer shutdown(t.Context())
	for range 3 {
		Login(t.Context())
	}
	m := checkutil.Metric(t, checkutil.Collect(t, r), "app.logins")
	sum, ok := m.Data.(metricdata.Sum[int64])
	if !ok || len(sum.DataPoints) != 1 || sum.DataPoints[0].Value != 3 {
		t.Errorf("app.logins = %+v, want a sum of 3", m.Data)
	}
}
