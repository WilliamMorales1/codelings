//go:build otellings_check

// REQUIRES: otelcol-contrib

/* HINT
  processors:
    attributes/scrub:
      actions:
        - key: http.request.header.authorization
          action: delete
        - key: user.email
          action: hash
        - key: pipeline.tier
          value: edge
          action: insert

and list attributes/scrub in the pipeline's processors, before batch.
The part after the slash is just a name; it lets you have several
processors of the same type.
*/

package collector3

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"testing"
	"time"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

func TestScrub(t *testing.T) {
	col := checkutil.StartCollector(t, "config.yaml")
	col.SendSpans(t, "collector3-check", func(ctx context.Context, tr trace.Tracer) {
		_, s := tr.Start(ctx, "POST /login", trace.WithAttributes(
			attribute.String("http.request.header.authorization", "Bearer hunter2-token"),
			attribute.String("user.email", "ada@example.com"),
		))
		s.End()
	})
	if !col.WaitFor("POST /login", 5*time.Second) {
		t.Fatalf("the span never reached the debug exporter:\n%s", col.Tail(15))
	}
	out := col.Output()
	if strings.Contains(out, "hunter2-token") {
		t.Errorf("the authorization header still reaches the exporter")
	}
	if strings.Contains(out, "ada@example.com") {
		t.Errorf("the raw e-mail address still reaches the exporter")
	}
	sum := sha256.Sum256([]byte("ada@example.com"))
	if !strings.Contains(out, "user.email: Str("+hex.EncodeToString(sum[:])+")") {
		t.Errorf("user.email should be replaced by its SHA-256 hash")
	}
	if !strings.Contains(out, "pipeline.tier: Str(edge)") {
		t.Errorf("pipeline.tier=edge was not added")
	}
}
