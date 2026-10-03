//go:build otellings_check

/* HINT
  return otelslog.NewLogger("otellings/logs1", otelslog.WithLoggerProvider(lp))

(and drop the os import.)
*/

package logs1

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/log"
	sdklog "go.opentelemetry.io/otel/sdk/log"
)

func TestBridge(t *testing.T) {
	rec := &checkutil.LogRecorder{}
	lp := sdklog.NewLoggerProvider(sdklog.WithProcessor(rec))
	NewLogger(lp).Info("user signed up", "plan", "pro")

	recs := rec.Records()
	if len(recs) != 1 {
		t.Fatalf("the LoggerProvider received %d records, want 1", len(recs))
	}
	r := recs[0]
	if got := r.Body().AsString(); got != "user signed up" {
		t.Errorf("body = %q", got)
	}
	if r.Severity() != log.SeverityInfo {
		t.Errorf("severity = %v, want INFO", r.Severity())
	}
	if v, _ := checkutil.Attr(checkutil.LogAttrs(r), "plan"); v.AsString() != "pro" {
		t.Errorf("attribute plan = %q, want pro", v.AsString())
	}
	if got := r.InstrumentationScope().Name; got != "otellings/logs1" {
		t.Errorf("scope = %q, want otellings/logs1", got)
	}
}
