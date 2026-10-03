package main

import (
	"fmt"
	"os"
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

// hyperlink renders an OSC 8 link; terminals without support just show label.
func hyperlink(target, label string) string {
	if noColor {
		return label
	}
	return "\x1b]8;;" + target + "\x1b\\" + label + "\x1b]8;;\x1b\\"
}

func fileLink(path, label string) string {
	return hyperlink("file://"+path, label)
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
	for line := range strings.SplitSeq(out, "\n") {
		fmt.Println("    " + line)
	}
}

func clearScreen() {
	fmt.Print("\x1b[2J\x1b[H")
}
