// setup2 -- resources from the environment
//
// Operators should be able to change what a service reports without a
// rebuild. The spec defines two environment variables for that:
//
//   OTEL_SERVICE_NAME=checkout-canary
//   OTEL_RESOURCE_ATTRIBUTES=deployment.environment.name=staging,team=payments
//
// resource.New builds a resource from *detectors*, applied in order, later
// ones overriding earlier ones. resource.WithFromEnv() is the detector for
// those two variables. There are detectors for host, process, OS,
// container, and more.
//
// Task: Resource hard-codes the service name, so OTEL_SERVICE_NAME is
// ignored. Keep "checkout" as the default, but let the environment
// override it and add attributes.
//

package setup2

import (
	"context"

	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.43.0"
)

// Resource describes this service.
func Resource(ctx context.Context) (*resource.Resource, error) {
	return resource.New(ctx,
		resource.WithSchemaURL(semconv.SchemaURL),
		resource.WithAttributes(semconv.ServiceName("checkout")),
	)
}
