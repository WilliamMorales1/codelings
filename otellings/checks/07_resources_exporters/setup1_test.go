//go:build otellings_check

/* HINT
  res, err := resource.Merge(resource.Default(), resource.NewWithAttributes(
      semconv.SchemaURL,
      semconv.ServiceName("checkout"),
      semconv.ServiceVersion("1.4.0"),
  ))
  ...
  sdktrace.WithResource(res)

The right-hand side of Merge wins on conflicts, which is why your
attributes go second.
*/

package setup1

import (
	"os"
	"testing"

	"go.opentelemetry.io/otel/sdk/trace/tracetest"
)

func TestResource(t *testing.T) {
	for _, k := range []string{"OTEL_SERVICE_NAME", "OTEL_RESOURCE_ATTRIBUTES"} {
		t.Setenv(k, "")
		os.Unsetenv(k)
	}
	sr := tracetest.NewSpanRecorder()
	tp, err := NewProvider(sr)
	if err != nil {
		t.Fatal(err)
	}
	_, span := tp.Tracer("check").Start(t.Context(), "pay")
	span.End()
	res := sr.Ended()[0].Resource()
	get := func(k string) string {
		for _, kv := range res.Attributes() {
			if string(kv.Key) == k {
				return kv.Value.Emit()
			}
		}
		return ""
	}
	if get("service.name") != "checkout" {
		t.Errorf("service.name = %q, want checkout", get("service.name"))
	}
	if get("service.version") != "1.4.0" {
		t.Errorf("service.version = %q, want 1.4.0", get("service.version"))
	}
	if get("telemetry.sdk.language") != "go" {
		t.Errorf("telemetry.sdk.language is missing: merge with resource.Default()")
	}
}
