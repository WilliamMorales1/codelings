// metrics1 -- a MeterProvider and a reader
//
// Metrics mirror tracing: code uses the API (otel.Meter(name) and
// instruments), the application installs an SDK MeterProvider.
//
// The difference is how data leaves. Spans are pushed when they end;
// metrics are *aggregated in memory* and collected by a Reader:
//   - PeriodicReader pushes every interval to an exporter (OTLP, stdout)
//   - ManualReader collects only when asked (tests use it)
//   - the Prometheus exporter is a reader that collects on each scrape
// A MeterProvider without a reader aggregates into the void.
//
// Task: Setup builds and installs a MeterProvider, but never attaches the
// reader it is given. Attach it (sdkmetric.WithReader).
//

package metrics1

import (
	"context"

	"go.opentelemetry.io/otel"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
)

// Setup installs the metrics SDK and returns its Shutdown.
func Setup(r sdkmetric.Reader) func(context.Context) error {
	mp := sdkmetric.NewMeterProvider(sdkmetric.WithReader(r))
	otel.SetMeterProvider(mp)
	return mp.Shutdown
}

// Login is instrumented code somewhere else in the program.
func Login(ctx context.Context) {
	logins, _ := otel.Meter("otellings/metrics1").Int64Counter("app.logins")
	logins.Add(ctx, 1)
}
