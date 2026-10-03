// tracing1 -- installing a TracerProvider
//
// Instrumented code only talks to the OpenTelemetry *API*: it calls
// otel.Tracer(name) and starts spans. Until an application installs an SDK
// TracerProvider, that API is a no-op: spans are created, cost next to
// nothing, and go nowhere. That is deliberate (libraries can instrument
// themselves without forcing an SDK on you), and it is also the #1 reason
// for "I added tracing and nothing shows up".
//
// Setup is what main() calls at startup. It builds an SDK TracerProvider
// that hands finished spans to the given SpanProcessor.
//
// Task: Setup builds the provider but Work's span still ends up in the
// no-op tracer. Make the provider the global one, so every otel.Tracer()
// call in the program uses it. Return its Shutdown so main can defer it.
//

package tracing1

import (
	"context"

	"go.opentelemetry.io/otel"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// Setup installs the SDK and returns the function that flushes and stops it.
func Setup(sp sdktrace.SpanProcessor) func(context.Context) error {
	tp := sdktrace.NewTracerProvider(sdktrace.WithSpanProcessor(sp))
	otel.SetTracerProvider(tp)
	return tp.Shutdown
}

// Work stands in for instrumented code elsewhere in the program.
func Work(ctx context.Context) {
	_, span := otel.Tracer("otellings/tracing1").Start(ctx, "work")
	defer span.End()
}
