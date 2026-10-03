//go:build otellings_check

/* HINT
logger.Log(ctx, level, "disk space low", slog.String(...), slog.Float64(...))
lets you pick the level in a variable; WarnContext/ErrorContext work too.
*/

package logs3

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/contrib/bridges/otelslog"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/log"
	sdklog "go.opentelemetry.io/otel/sdk/log"
)

func TestSeverityAndStructure(t *testing.T) {
	rec := &checkutil.LogRecorder{}
	lp := sdklog.NewLoggerProvider(sdklog.WithProcessor(rec))
	logger := otelslog.NewLogger("check", otelslog.WithLoggerProvider(lp))

	ReportDisk(t.Context(), logger, "/dev/sda1", 0.50)
	ReportDisk(t.Context(), logger, "/dev/sda1", 0.07)
	ReportDisk(t.Context(), logger, "/dev/nvme0n1", 0.01)

	recs := rec.Records()
	if len(recs) != 2 {
		t.Fatalf("got %d log records, want 2 (nothing at 50%% free)", len(recs))
	}
	want := []struct {
		sev    log.Severity
		device string
		free   float64
	}{{log.SeverityWarn, "/dev/sda1", 0.07}, {log.SeverityError, "/dev/nvme0n1", 0.01}}
	for i, w := range want {
		r := recs[i]
		if r.Body().AsString() != "disk space low" {
			t.Errorf("record %d body = %q, want the constant \"disk space low\"", i, r.Body().AsString())
		}
		if r.Severity() != w.sev {
			t.Errorf("record %d severity = %v, want %v", i, r.Severity(), w.sev)
		}
		attrs := checkutil.LogAttrs(r)
		if v, _ := checkutil.Attr(attrs, "disk.device"); v.AsString() != w.device {
			t.Errorf("record %d disk.device = %q, want %q", i, v.AsString(), w.device)
		}
		v, _ := checkutil.Attr(attrs, "disk.free_ratio")
		if v.Type() != attribute.FLOAT64 || v.AsFloat64() != w.free {
			t.Errorf("record %d disk.free_ratio = %s (%s), want float %v", i, v.Emit(), v.Type(), w.free)
		}
	}
}
