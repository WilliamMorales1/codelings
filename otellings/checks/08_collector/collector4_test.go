//go:build otellings_check

// REQUIRES: otelcol-contrib

/* HINT
    trace_conditions:
      - span.attributes["url.path"] == "/healthz"

Quote the whole condition in YAML if you like ('...'), and put
filter/health first-ish in the pipeline: `processors: [filter/health, batch]`.
*/

package collector4

import (
	"context"
	"strings"
	"testing"
	"time"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

func TestHealthzDropped(t *testing.T) {
	col := checkutil.StartCollector(t, "config.yaml")
	col.SendSpans(t, "collector4-check", func(ctx context.Context, tr trace.Tracer) {
		for _, p := range []string{"/healthz", "/books", "/healthz"} {
			_, s := tr.Start(ctx, "GET "+p, trace.WithAttributes(attribute.String("url.path", p)))
			s.End()
		}
	})
	if !col.WaitFor("GET /books", 5*time.Second) {
		t.Fatalf("the /books span never reached the debug exporter:\n%s", col.Tail(15))
	}
	time.Sleep(300 * time.Millisecond)
	if strings.Contains(col.Output(), "GET /healthz") {
		t.Errorf("/healthz spans still reach the exporter")
	}
}
