// logs1 -- the slog bridge
//
// OpenTelemetry does not ask you to adopt a new logging API. Instead a
// *bridge* turns records from the logger you already use into OTel log
// records, which then flow through a LoggerProvider, processors and
// exporters just like spans. For log/slog the bridge is
//
//   go.opentelemetry.io/contrib/bridges/otelslog
//
// otelslog.NewLogger(name, opts...) returns a *slog.Logger whose handler
// emits to a LoggerProvider (the global one unless you pass
// otelslog.WithLoggerProvider). The name becomes the instrumentation scope.
//
// Task: NewLogger still writes text to stderr. Return an otelslog logger
// named "otellings/logs1" that uses lp.
//

package logs1

import (
	"log/slog"

	"go.opentelemetry.io/contrib/bridges/otelslog"
	"go.opentelemetry.io/otel/log"
)

// NewLogger returns the application's logger.
func NewLogger(lp log.LoggerProvider) *slog.Logger {
	return otelslog.NewLogger("otellings/logs1", otelslog.WithLoggerProvider(lp))
}
