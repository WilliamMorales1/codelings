// logs3 -- severity and structure
//
// Two habits make logs searchable instead of greppable:
//
//   - severity is a field, not a word in the text. slog levels map onto
//     OTel severities (Warn -> WARN, Error -> ERROR), which backends
//     filter and alert on.
//   - the message is a *constant* describing the event; the variable parts
//     are attributes. "disk space low" with disk.device=/dev/sda1 can be
//     counted and grouped; "WARNING: /dev/sda1 is at 7% free" cannot.
//
// Task: rewrite ReportDisk to log the constant message "disk space low"
// with the attributes "disk.device" (string) and "disk.free_ratio" (the
// float, e.g. 0.07), at Warn level when free < 10% and Error level when
// free < 2%. Above 10% it logs nothing. Keep passing ctx.
//

package logs3

import (
	"context"
	"log/slog"
)

// ReportDisk logs if device is running out of space.
func ReportDisk(ctx context.Context, logger *slog.Logger, device string, free float64) {
	level := slog.LevelWarn
	switch {
	case free < 0.02:
		level = slog.LevelError
	case free >= 0.10:
		return
	}
	logger.Log(ctx, level, "disk space low",
		slog.String("disk.device", device),
		slog.Float64("disk.free_ratio", free),
	)
}
