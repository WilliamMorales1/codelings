// setup3 -- configuring the OTLP exporter from the environment
//
// OTLP is OpenTelemetry's wire protocol (protobuf over gRPC or HTTP). Every
// OTLP exporter reads the same standard variables:
//
//   OTEL_EXPORTER_OTLP_ENDPOINT   base URL, e.g. http://localhost:4318
//                                 (the HTTP exporter appends /v1/traces)
//   OTEL_EXPORTER_OTLP_HEADERS    key=value,... e.g. an API key
//   OTEL_EXPORTER_OTLP_TIMEOUT    milliseconds
//   ..._TRACES_ENDPOINT etc.      per-signal overrides (used as-is, no path appended)
//
// Options passed in code take precedence over the environment. So a
// hard-coded endpoint makes the variables useless and pins every
// deployment to one collector.
//
// Task: NewExporter hard-codes the endpoint. Let the environment decide:
// build the exporter with no endpoint options at all.
//

package setup3

import (
	"context"

	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// NewExporter returns the span exporter for this service.
func NewExporter(ctx context.Context) (sdktrace.SpanExporter, error) {
	return otlptracehttp.New(ctx)
}
