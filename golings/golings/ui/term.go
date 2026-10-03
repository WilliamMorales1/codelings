package ui

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/fatih/color"
)

// FileLink renders path as an OSC 8 hyperlink to the absolute file; NO_COLOR or a dumb terminal gets plain text.
func FileLink(path string) string {
	abs, err := filepath.Abs(path)
	if err != nil || color.NoColor {
		return path
	}
	return "\x1b]8;;file://" + abs + "\x1b\\" + path + "\x1b]8;;\x1b\\"
}

// ProgressBar renders a fixed-width bar in the style shared by the other -lings runners.
func ProgressBar(done, total int) string {
	const width = 32
	filled := 0
	if total > 0 {
		filled = width * done / total
	}
	bar := strings.Repeat("#", filled) + strings.Repeat("-", width-filled)
	return fmt.Sprintf("Progress: [%s] %d/%d", color.GreenString(bar), done, total)
}

// ClearScreen wipes the terminal with ANSI codes, so no `clear` binary is needed.
func ClearScreen() {
	fmt.Fprint(os.Stdout, "\x1b[2J\x1b[H")
}
