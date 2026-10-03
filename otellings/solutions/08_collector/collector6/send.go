// collector6 -- end to end: Go program -> collector
//
// Time to connect both halves. Send is a small batch job that exports its
// trace over OTLP/HTTP to the collector configured in config.yaml. The
// check starts that collector and calls Send with its base URL
// (e.g. http://127.0.0.1:4318).
//
// Nothing arrives. Read the error Send returns (the check prints it) and
// fix Send. Careful: since otel-go 1.45, WithEndpointURL uses the URL
// *exactly as given*; it no longer appends /v1/traces for you (which is
// what WithEndpoint + WithInsecure, and OTEL_EXPORTER_OTLP_ENDPOINT, do).
//
// Want to watch it for real? Run the collector yourself:
//   otelcol-contrib --config config.yaml
// and point any OTLP-speaking program at http://127.0.0.1:4318.
//

package collector6

import (
	"context"
	"errors"

	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.43.0"
)

// Send runs the nightly report and exports its trace to the collector at baseURL.
func Send(ctx context.Context, baseURL string) (err error) {
	exp, err := otlptracehttp.New(ctx, otlptracehttp.WithEndpointURL(baseURL+"/v1/traces"))
	if err != nil {
		return err
	}
	res, err := resource.Merge(resource.Default(),
		resource.NewWithAttributes(semconv.SchemaURL, semconv.ServiceName("reporter")))
	if err != nil {
		return err
	}
	tp := sdktrace.NewTracerProvider(sdktrace.WithBatcher(exp), sdktrace.WithResource(res))
	defer func() { err = errors.Join(err, tp.Shutdown(ctx)) }()

	ctx, span := tp.Tracer("otellings/collector6").Start(ctx, "nightly-report")
	defer span.End()
	_, query := tp.Tracer("otellings/collector6").Start(ctx, "query-sales")
	query.End()
	return nil
}
