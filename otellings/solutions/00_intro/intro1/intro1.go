// intro1 -- how otellings works
//
// Welcome! Every exercise is a directory under exercises/. You edit the files
// in it until the hidden check (checks/<chapter>/<name>_test.go) passes; then
// the exercise is done and otellings moves on.
//
// Keep `otellings watch` running in a second terminal: it re-checks every time
// you save. Checks are ordinary Go tests that plug an in-memory exporter into
// your code and look at the spans, metrics and logs it produced. Nothing is
// sent anywhere; no Jaeger, no docker.
//
// This file starts one span with the global tracer. The check installs a
// TracerProvider that records spans in memory, calls Hello, and looks for a
// span named "hello".
//
// Task: give the span the name the check is looking for, and save.

package intro1

import (
	"context"

	"go.opentelemetry.io/otel"
)

// Hello records a single span. The instrumentation scope name is usually the
// import path of the package doing the instrumenting.
func Hello(ctx context.Context) string {
	_, span := otel.Tracer("otellings/intro1").Start(ctx, "hello")
	defer span.End()
	return "hello, telemetry"
}
