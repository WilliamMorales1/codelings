// setup4 -- batch, don't sync
//
// sdktrace.WithSyncer(exp) wraps the exporter in a *simple* span processor:
// every span.End() blocks until that one span has been sent over the
// network. Fine for tests and demos; in a server it adds an export round
// trip to every request, and a slow collector slows your service down.
//
// sdktrace.WithBatcher(exp) queues ended spans and exports them in batches
// from a background goroutine. End() returns immediately. The price: you
// must Shutdown (or ForceFlush) before exiting, as in tracing2, and a full
// queue drops spans rather than block.
//
// Task: switch the provider to batching.
//

package setup4

import (
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// NewProvider builds the service's TracerProvider.
func NewProvider(exp sdktrace.SpanExporter) *sdktrace.TracerProvider {
	return sdktrace.NewTracerProvider(sdktrace.WithBatcher(exp))
}
