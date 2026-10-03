//go:build otellings_check

// REQUIRES: otelcol-contrib

/* HINT
  processors:
    memory_limiter:
      check_interval: 1s
      limit_percentage: 80
      spike_limit_percentage: 20

  ...
      processors: [memory_limiter, batch]

`otelcol-contrib print-config --config config.yaml` shows the config the
collector actually resolved, defaults included.
*/

package collector2

import (
	"context"
	"slices"
	"testing"
	"time"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/trace"
)

func TestProcessorOrder(t *testing.T) {
	cfg := checkutil.ResolvedConfig(t, "config.yaml")
	var procs []string
	for _, p := range checkutil.Dig(cfg, "service", "pipelines", "traces", "processors").([]any) {
		procs = append(procs, p.(string))
	}
	if !slices.Equal(procs, []string{"memory_limiter", "batch"}) {
		t.Errorf("traces processors = %v, want [memory_limiter batch]", procs)
	}
	if v, _ := checkutil.Dig(cfg, "processors", "memory_limiter", "limit_percentage").(float64); v != 80 {
		t.Errorf("memory_limiter limit_percentage = %v, want 80", v)
	}
	if v, _ := checkutil.Dig(cfg, "processors", "memory_limiter", "spike_limit_percentage").(float64); v != 20 {
		t.Errorf("memory_limiter spike_limit_percentage = %v, want 20", v)
	}

	col := checkutil.StartCollector(t, "config.yaml")
	col.SendSpans(t, "collector2-check", func(ctx context.Context, tr trace.Tracer) {
		_, s := tr.Start(ctx, "through-the-limiter")
		s.End()
	})
	if !col.WaitFor("through-the-limiter", 5*time.Second) {
		t.Errorf("the span never reached the debug exporter:\n%s", col.Tail(15))
	}
}
