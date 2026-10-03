// Command otellings is a rustlings-style course for OpenTelemetry in Go and the OpenTelemetry Collector.
package main

import (
	"fmt"
	"maps"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"time"
)

const usage = `otellings - small exercises for OpenTelemetry in Go and the OpenTelemetry Collector

USAGE:
    otellings [COMMAND]

COMMANDS:
    verify [CHAPTER]    Check exercises in order, stopping at the first unsolved one (default)
    watch [CHAPTER]     Same as verify, but re-checks every time you save a file
    run [NAME]          Check a single exercise (defaults to the next unsolved one)
    hint [NAME]         Print the hint for an exercise
    list                Show every exercise and its status
    solution NAME       Print the reference solution (every file of it)
    reset NAME          Restore an exercise to its original, unsolved state
    doctor              Show which external tools are installed and how to get the rest
    selftest [-v] [-j N] [CHAPTER]
                        Course maintenance: solutions pass, untouched exercises fail
    help                Show this message

CHAPTER is a prefix such as 03 or 03_propagation. Every exercise is a directory.
Fix the files and save: once the check passes the exercise is done and
otellings moves you on to the next one.`

func main() {
	os.Exit(run(os.Args[1:]))
}

func run(args []string) int {
	cmd := "verify"
	if len(args) > 0 {
		cmd, args = args[0], args[1:]
	}
	arg := func() string {
		if len(args) > 0 {
			return args[0]
		}
		return ""
	}
	switch cmd {
	case "help", "-h", "--help":
		fmt.Println(usage)
		return 0
	}
	root, err := findRoot()
	if err != nil {
		say(red, "%v", err)
		return 2
	}
	prog = loadProgress(root)
	exs, err := discover(root)
	if err != nil {
		say(red, "%v", err)
		return 2
	}
	switch cmd {
	case "verify":
		return cmdVerify(filterChapter(exs, arg()), nil)
	case "watch":
		return cmdWatch(root, arg())
	case "run":
		return cmdRun(exs, arg())
	case "hint":
		return cmdHint(exs, arg())
	case "list":
		return cmdList(exs)
	case "solution":
		return withExercise(exs, arg(), cmdSolution)
	case "reset":
		return withExercise(exs, arg(), cmdReset)
	case "doctor":
		return cmdDoctor(root, exs)
	case "selftest":
		jobs, prefix, verbose := 4, "", false
		for i := 0; i < len(args); i++ {
			if args[i] == "-v" {
				verbose = true
			} else if args[i] == "-j" && i+1 < len(args) {
				jobs, _ = strconv.Atoi(args[i+1])
				i++
			} else {
				prefix = args[i]
			}
		}
		return cmdSelftest(filterChapter(exs, prefix), max(jobs, 1), verbose)
	}
	fmt.Println(usage)
	return 2
}

func withExercise(exs []Exercise, name string, f func(Exercise) int) int {
	if name == "" {
		say(red, "which exercise? (try `otellings list`)")
		return 2
	}
	e, err := find(exs, name)
	if err != nil {
		say(red, "%v", err)
		return 2
	}
	return f(e)
}

func filterChapter(exs []Exercise, prefix string) []Exercise {
	if prefix == "" {
		return exs
	}
	return slices.DeleteFunc(slices.Clone(exs), func(e Exercise) bool {
		return !strings.HasPrefix(e.Chapter, prefix)
	})
}

func showHint(e Exercise) {
	h := e.Hint()
	if h == "" {
		say(dim, "(this exercise has no hint)")
		return
	}
	say(cyan, "Hint:")
	indent(h)
}

// report prints one outcome and returns true when the learner may move on.
func report(e Exercise, o Outcome) bool {
	abs, rel := editFile(e)
	switch o.Status {
	case Missing:
		say(red, "x %s needs tools that are not installed: %s", e.ID(), strings.Join(o.Missing, ", "))
		for _, t := range o.Missing {
			fmt.Printf("    %-12s %s\n", t, installHint(t))
		}
		fmt.Println("  Install them (see `otellings doctor`), or work on another chapter with `otellings watch NN`.")
	case Failed:
		say(red, "x %s fails.", e.ID())
		fmt.Println("  File: " + fileLink(abs, rel))
		indent(o.Output)
		fmt.Println()
		showHint(e)
	case Passed:
		say(green, "v %s passes!", e.ID())
		return true
	}
	return false
}

type cached struct {
	stamp   string
	outcome Outcome
}

// check runs an exercise, recording passes; watch passes a cache keyed by file stamps.
func check(e Exercise, cache map[string]cached) Outcome {
	st := e.Stamp()
	if c, ok := cache[e.ID()]; ok && c.stamp == st {
		return c.outcome
	}
	o := e.Check()
	prog.Record(e, o)
	if cache != nil {
		cache[e.ID()] = cached{st, o}
	}
	return o
}

func cmdVerify(exs []Exercise, cache map[string]cached) int {
	if len(exs) == 0 {
		say(red, "no exercises match")
		return 2
	}
	for i, e := range exs {
		if prog.Done(e) {
			continue
		}
		o := check(e, cache)
		if o.Status == Passed {
			continue
		}
		fmt.Println(progressBar(i, len(exs)))
		fmt.Println()
		report(e, o)
		return 1
	}
	fmt.Println(progressBar(len(exs), len(exs)))
	say(green, "All %d exercises complete. Every span has a parent, every metric a unit.", len(exs))
	return 0
}

func cmdWatch(root, prefix string) int {
	cache := map[string]cached{}
	last := ""
	for {
		// Rediscover each round so reset/new exercises show up.
		exs, err := discover(root)
		if err != nil {
			say(red, "%v", err)
			return 2
		}
		exs = filterChapter(exs, prefix)
		var key strings.Builder
		for _, e := range exs {
			key.WriteString(e.Stamp())
		}
		if key.String() != last {
			last = key.String()
			clearScreen()
			cmdVerify(exs, cache)
			fmt.Println()
			say(dim, "watching... (Ctrl-C to quit)")
		}
		time.Sleep(700 * time.Millisecond)
	}
}

func nextUnsolved(exs []Exercise) (Exercise, Outcome, bool) {
	for _, e := range exs {
		if prog.Done(e) {
			continue
		}
		if o := check(e, nil); o.Status != Passed {
			return e, o, true
		}
	}
	return Exercise{}, Outcome{}, false
}

func cmdRun(exs []Exercise, name string) int {
	if name == "" {
		e, o, ok := nextUnsolved(exs)
		if !ok {
			say(green, "Nothing left to run: every exercise passes.")
			return 0
		}
		report(e, o)
		return 1
	}
	e, err := find(exs, name)
	if err != nil {
		say(red, "%v", err)
		return 2
	}
	if report(e, check(e, nil)) {
		return 0
	}
	return 1
}

func cmdHint(exs []Exercise, name string) int {
	var e Exercise
	if name == "" {
		var ok bool
		if e, _, ok = nextUnsolved(exs); !ok {
			say(green, "Every exercise already passes.")
			return 0
		}
	} else {
		var err error
		if e, err = find(exs, name); err != nil {
			say(red, "%v", err)
			return 2
		}
	}
	say(bold, "%s", e.ID())
	showHint(e)
	return 0
}

func cmdList(exs []Exercise) int {
	done := 0
	for _, e := range exs {
		label := paint(yellow, "PENDING")
		switch {
		case prog.Done(e):
			label = paint(green, "DONE   ")
			done++
		case len(missingTools(e.Requires())) > 0:
			label = paint(dim, "NO TOOL")
		}
		abs, rel := editFile(e)
		fmt.Printf("%s  %-30s %s\n", label, e.ID(), fileLink(abs, rel))
	}
	fmt.Println()
	fmt.Println(progressBar(done, len(exs)))
	return 0
}

func cmdSolution(e Exercise) int {
	fs := files(e.SolutionDir())
	if len(fs) == 0 {
		say(yellow, "no solution at %s", e.SolutionDir())
		return 1
	}
	say(bold, "Solution for %s:", e.ID())
	for _, f := range fs {
		rel, _ := filepath.Rel(e.root, f)
		b, err := os.ReadFile(f)
		if err != nil {
			continue
		}
		fmt.Println()
		say(cyan, "==> %s", rel)
		fmt.Print(string(b))
		if len(b) > 0 && b[len(b)-1] != '\n' {
			fmt.Println()
		}
	}
	return 0
}

func cmdReset(e Exercise) int {
	if _, err := os.Stat(e.TemplateDir()); err != nil {
		say(red, "no pristine copy at %s", e.TemplateDir())
		return 1
	}
	if err := os.RemoveAll(e.Dir()); err != nil {
		say(red, "%v", err)
		return 1
	}
	if err := os.CopyFS(e.Dir(), os.DirFS(e.TemplateDir())); err != nil {
		say(red, "%v", err)
		return 1
	}
	prog.Forget(e)
	say(yellow, "reset %s to its original state", e.ID())
	return 0
}

func cmdDoctor(root string, exs []Exercise) int {
	usedBy := map[string][]string{}
	for _, e := range exs {
		for _, t := range e.Requires() {
			if !slices.Contains(usedBy[t], e.Chapter) {
				usedBy[t] = append(usedBy[t], e.Chapter)
			}
		}
	}
	missing := 0
	for _, t := range slices.Sorted(maps.Keys(usedBy)) {
		chapters := strings.Join(usedBy[t], " ")
		if len(usedBy[t]) > 3 {
			chapters = "all"
		}
		p, err := exec.LookPath(t)
		if err != nil {
			missing++
			fmt.Printf("%s %-16s %s %s\n", paint(red, "missing"), t, installHint(t), paint(dim, "("+chapters+")"))
			continue
		}
		fmt.Printf("%s %-16s %s %s %s\n", paint(green, "ok     "), t, p, toolVersion(t), paint(dim, "("+chapters+")"))
	}
	if _, err := exec.LookPath("go"); err == nil {
		// Downloading the OTel modules up front keeps the first check from looking hung.
		cmd := exec.Command("go", "mod", "download")
		cmd.Dir = root
		cmd.Env = append(os.Environ(), "GOWORK=off")
		if out, err := cmd.CombinedOutput(); err != nil {
			missing++
			say(red, "go mod download failed (network?):")
			indent(string(out))
		} else {
			fmt.Printf("%s %-16s %s\n", paint(green, "ok     "), "go modules", paint(dim, "downloaded to "+goEnv("GOMODCACHE")))
		}
	}
	fmt.Println()
	if missing == 0 {
		say(green, "Everything is installed.")
		return 0
	}
	say(yellow, "%d missing. Chapters whose tools are missing are reported as NO TOOL.", missing)
	return 1
}

func toolVersion(tool string) string {
	var out []byte
	switch tool {
	case "go":
		out, _ = exec.Command("go", "env", "GOVERSION").Output()
	case "otelcol-contrib":
		out, _ = exec.Command(tool, "--version").Output()
	}
	return strings.TrimSpace(string(out))
}

func goEnv(key string) string {
	out, _ := exec.Command("go", "env", key).Output()
	return strings.TrimSpace(string(out))
}
