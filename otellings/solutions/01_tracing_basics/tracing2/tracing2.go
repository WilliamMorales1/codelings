// tracing2 -- shutting down flushes the batch
//
// Production providers use a *batching* span processor: finished spans are
// queued and exported in the background every few seconds. That keeps the
// hot path fast, but it means spans sit in memory for a while. A short-lived
// program (a CLI, a cron job, a Lambda) that just returns loses them.
//
// TracerProvider.Shutdown flushes the queue, waits for the exporter, and
// stops the background goroutine. ForceFlush only does the first two.
//
// Task: Run traces three steps of a nightly job and returns. The check calls
// Run and then immediately looks at what the exporter received: nothing.
// Make sure the provider is shut down before Run returns, and report a
// failed shutdown as Run's error.
//

package tracing2

import (
	"context"
	"errors"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// Run executes the job, exporting its spans through exp.
func Run(ctx context.Context, exp sdktrace.SpanExporter) (err error) {
	tp := sdktrace.NewTracerProvider(sdktrace.WithBatcher(exp))
	defer func() { err = errors.Join(err, tp.Shutdown(ctx)) }()
	tr := tp.Tracer("otellings/tracing2")

	for _, step := range []string{"download", "transform", "upload"} {
		_, span := tr.Start(ctx, step)
		// ... the real work would happen here ...
		span.End()
	}
	return nil
}
