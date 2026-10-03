// Package cli holds the plain (non-TUI) commands, styled like the other -lings runners.
package cli

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

type style string

const (
	bold   style = "\x1b[1m"
	dim    style = "\x1b[2m"
	red    style = "\x1b[31m"
	green  style = "\x1b[32m"
	yellow style = "\x1b[33m"
	cyan   style = "\x1b[36m"
)

var noColor = os.Getenv("NO_COLOR") != ""

func paint(st style, s string) string {
	if noColor {
		return s
	}
	return string(st) + s + "\x1b[0m"
}

func say(st style, format string, args ...any) {
	fmt.Println(paint(st, fmt.Sprintf(format, args...)))
}

// FileLink renders path as an OSC 8 hyperlink; terminals without support just show the label.
func FileLink(path string) string {
	abs, err := filepath.Abs(path)
	if err != nil || noColor {
		return path
	}
	return "\x1b]8;;file://" + abs + "\x1b\\" + path + "\x1b]8;;\x1b\\"
}

func progressBar(done, total int) string {
	const width = 32
	filled := 0
	if total > 0 {
		filled = width * done / total
	}
	bar := strings.Repeat("#", filled) + strings.Repeat("-", width-filled)
	return fmt.Sprintf("Progress: [%s] %d/%d", paint(green, bar), done, total)
}

func indent(out string) {
	out = strings.TrimRight(out, "\n")
	if out == "" {
		return
	}
	for _, line := range strings.Split(out, "\n") {
		fmt.Println("    " + line)
	}
}
