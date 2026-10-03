//go:build otellings_check

/* HINT
Add resource.WithFromEnv() *after* resource.WithAttributes(...), so the
environment wins over the default.
*/

package setup2

import (
	"os"
	"testing"

	"go.opentelemetry.io/otel/sdk/resource"
)

func attr(r *resource.Resource, k string) string {
	for _, kv := range r.Attributes() {
		if string(kv.Key) == k {
			return kv.Value.Emit()
		}
	}
	return ""
}

func TestEnvOverrides(t *testing.T) {
	t.Run("defaults", func(t *testing.T) {
		for _, k := range []string{"OTEL_SERVICE_NAME", "OTEL_RESOURCE_ATTRIBUTES"} {
			t.Setenv(k, "")
			os.Unsetenv(k)
		}
		r, err := Resource(t.Context())
		if err != nil {
			t.Fatal(err)
		}
		if got := attr(r, "service.name"); got != "checkout" {
			t.Errorf("service.name = %q without env, want checkout", got)
		}
	})
	t.Run("env", func(t *testing.T) {
		t.Setenv("OTEL_SERVICE_NAME", "checkout-canary")
		t.Setenv("OTEL_RESOURCE_ATTRIBUTES", "deployment.environment.name=staging,team=payments")
		r, err := Resource(t.Context())
		if err != nil {
			t.Fatal(err)
		}
		if got := attr(r, "service.name"); got != "checkout-canary" {
			t.Errorf("service.name = %q, want checkout-canary from OTEL_SERVICE_NAME", got)
		}
		if got := attr(r, "deployment.environment.name"); got != "staging" {
			t.Errorf("deployment.environment.name = %q, want staging from OTEL_RESOURCE_ATTRIBUTES", got)
		}
		if got := attr(r, "team"); got != "payments" {
			t.Errorf("team = %q, want payments", got)
		}
	})
}
