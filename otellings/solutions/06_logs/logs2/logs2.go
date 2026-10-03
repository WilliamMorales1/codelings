// logs2 -- logs that know their trace
//
// The killer feature of OTel logs: every record emitted while a span is
// active carries that span's trace ID and span ID, so a backend can jump
// from a slow span straight to its log lines and back.
//
// The bridge finds the span in the context.Context, so it only works if
// the context reaches slog: logger.InfoContext(ctx, ...), not
// logger.Info(...). The non-Context methods use context.Background().
//
// Task: make the log line inside Handle carry the "handle" span's IDs.
//

package logs2

import (
	"context"
	"log/slog"

	"go.opentelemetry.io/otel/trace"
)

// Handle processes an order and logs about it.
func Handle(ctx context.Context, tr trace.Tracer, logger *slog.Logger, orderID string) {
	ctx, span := tr.Start(ctx, "handle")
	defer span.End()
	logger.InfoContext(ctx, "processing order", "order.id", orderID)
}
