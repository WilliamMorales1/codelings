//go:build otellings_check

/* HINT
Building a provider is not enough: the global API has to be told about it.
Look at otel.SetTracerProvider.
*/

package tracing1

import (
	"testing"

	"go.opentelemetry.io/otel/sdk/trace/tracetest"
)

func TestSetupInstallsGlobalProvider(t *testing.T) {
	sr := tracetest.NewSpanRecorder()
	shutdown := Setup(sr)
	if shutdown == nil {
		t.Fatal("Setup returned a nil shutdown function")
	}
	Work(t.Context())
	if n := len(sr.Ended()); n != 1 {
		t.Fatalf("Work ended %d spans in your provider, want 1: the global tracer is still the no-op one", n)
	}
	if got := sr.Ended()[0].Name(); got != "work" {
		t.Errorf("span name = %q, want work", got)
	}
	if err := shutdown(t.Context()); err != nil {
		t.Errorf("shutdown: %v", err)
	}
}
