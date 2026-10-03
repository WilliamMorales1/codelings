//go:build otellings_check

// REQUIRES: otelcol-contrib

/* HINT
A component only runs when a pipeline uses it. Under `service:` add

  pipelines:
    traces:
      receivers: [otlp]
      exporters: [debug]

Try it yourself: otelcol-contrib validate --config config.yaml
*/

package collector1

import (
	"context"
	"strings"
	"testing"
	"time"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/trace"
)

func TestPipeline(t *testing.T) {
	col := checkutil.StartCollector(t, "config.yaml")
	col.SendSpans(t, "collector1-check", func(ctx context.Context, tr trace.Tracer) {
		_, span := tr.Start(ctx, "first-span-through-a-collector")
		span.End()
	})
	if !col.WaitFor("first-span-through-a-collector", 5*time.Second) {
		t.Fatalf("the span never showed up in the debug exporter output:\n%s", col.Tail(15))
	}
	if !strings.Contains(col.Output(), "service.name: Str(collector1-check)") {
		t.Errorf("expected detailed output with resource attributes; is the debug exporter's verbosity detailed?")
	}
}
