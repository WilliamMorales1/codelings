//go:build otellings_check

/* HINT
  logger.InfoContext(ctx, "processing order", "order.id", orderID)

Every slog method has a ...Context twin; prefer them everywhere.
*/

package logs2

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/contrib/bridges/otelslog"
	sdklog "go.opentelemetry.io/otel/sdk/log"
)

func TestCorrelation(t *testing.T) {
	rec := &checkutil.LogRecorder{}
	lp := sdklog.NewLoggerProvider(sdklog.WithProcessor(rec))
	logger := otelslog.NewLogger("check", otelslog.WithLoggerProvider(lp))
	sr, tp := checkutil.Tracing(t)

	Handle(t.Context(), tp.Tracer("check"), logger, "ord-9")

	span := checkutil.Span(t, sr.Ended(), "handle")
	recs := rec.Records()
	if len(recs) != 1 {
		t.Fatalf("got %d log records, want 1", len(recs))
	}
	r := recs[0]
	if r.TraceID() != span.SpanContext().TraceID() || r.SpanID() != span.SpanContext().SpanID() {
		t.Errorf("log record has trace %s span %s, want the handle span's %s / %s",
			r.TraceID(), r.SpanID(), span.SpanContext().TraceID(), span.SpanContext().SpanID())
	}
}
