// setup1 -- resources: who is sending this?
//
// A *resource* describes the entity producing telemetry: service.name,
// service.version, host, container, cloud region... It is attached once to
// the provider and applies to every span (and metric, and log) it emits.
// Without service.name, every backend files your spans under
// "unknown_service:<binary name>".
//
// resource.Default() already knows the SDK (telemetry.sdk.*) and reads the
// OTEL_* environment variables. Merge your own attributes on top of it.
//
// resource.Merge fails if both sides carry *different* semconv schema URLs,
// so build your attributes with the same semconv version the SDK uses
// (semconv/v1.43.0 for this SDK release).
//
// Task: give the provider a resource with service.name "checkout" and
// service.version "1.4.0", merged with resource.Default().
//

package setup1

import (
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.43.0"
)

// NewProvider builds the checkout service's TracerProvider.
func NewProvider(sp sdktrace.SpanProcessor) (*sdktrace.TracerProvider, error) {
	res, err := resource.Merge(resource.Default(), resource.NewWithAttributes(
		semconv.SchemaURL,
		semconv.ServiceName("checkout"),
		semconv.ServiceVersion("1.4.0"),
	))
	if err != nil {
		return nil, err
	}
	return sdktrace.NewTracerProvider(
		sdktrace.WithSpanProcessor(sp),
		sdktrace.WithResource(res),
	), nil
}
