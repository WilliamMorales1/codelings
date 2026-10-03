// Command systemdlings is a rustlings-style course for systemd units, run against your own user manager.
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

const usage = `systemdlings - small exercises for writing systemd units, checked in your user manager

USAGE:
    systemdlings [COMMAND]

COMMANDS:
    verify [CHAPTER]    Check exercises in order, stopping at the first unsolved one (default)
    watch [CHAPTER]     Same as verify, but re-checks every time you save a file
    run [NAME]          Check a single exercise (defaults to the next unsolved one)
    hint [NAME]         Print the hint for an exercise
    list                Show every exercise and its status
    solution NAME       Print the reference solution (every file of it)
    reset NAME          Restore an exercise to its original, unsolved state
    doctor              Show which external tools are installed and how to get the rest
    clean               Stop and remove every leftover systemdlings-* unit (checks do this themselves)
    selftest [-j N] [CHAPTER]
                        Course maintenance: solutions pass, untouched exercises fail
    help                Show this message

CHAPTER is a prefix such as 03 or 03_dependencies. Every exercise is a directory.
Fix the files and save: once the check passes the exercise is done and
systemdlings moves you on to the next one.

Checks only ever touch units named systemdlings-*, only in your user manager
(systemctl --user), installed under $XDG_RUNTIME_DIR/systemd/user, and remove
them again when they finish.`

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
	case "clean":
		return cmdClean()
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
		return cmdDoctor(exs)
	case "selftest":
		jobs, prefix := 2, ""
		for i := 0; i < len(args); i++ {
			if args[i] == "-j" && i+1 < len(args) {
				jobs, _ = strconv.Atoi(args[i+1])
				i++
			} else {
				prefix = args[i]
			}
		}
		return cmdSelftest(root, filterChapter(exs, prefix), max(jobs, 1))
	}
	fmt.Println(usage)
	return 2
}

func withExercise(exs []Exercise, name string, f func(Exercise) int) int {
	if name == "" {
		say(red, "which exercise? (try `systemdlings list`)")
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
		fmt.Println("  Install them (see `systemdlings doctor`), or work on another chapter with `systemdlings watch NN`.")
	case Failed:
		say(red, "x %s fails.", e.ID())
		fmt.Println("  File: " + fileLink(abs, rel))
		indent(o.Output)
		fmt.Println()
		showHint(e)
	case Passed:
		say(green, "v %s passes!", e.ID())
		indent(o.Output)
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
	say(green, "All %d exercises complete. Your units start, stop and log like they should.", len(exs))
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

func cmdDoctor(exs []Exercise) int {
	usedBy := map[string][]string{"bash": {"all"}, "jq": {"checks"}}
	for _, e := range exs {
		for _, t := range e.Requires() {
			if t != userManager && !slices.Contains(usedBy[t], e.Chapter) {
				usedBy[t] = append(usedBy[t], e.Chapter)
			}
		}
	}
	missing := 0
	for _, t := range slices.Sorted(maps.Keys(usedBy)) {
		chapters := strings.Join(usedBy[t], " ")
		if p, err := exec.LookPath(t); err == nil {
			fmt.Printf("%s %-12s %s %s\n", paint(green, "ok     "), t, p, paint(dim, "("+chapters+")"))
			continue
		}
		missing++
		fmt.Printf("%s %-12s %s %s\n", paint(red, "missing"), t, installHint(t), paint(dim, "("+chapters+")"))
	}
	if state, err := userManagerState(); err != nil {
		missing++
		say(red, "the systemd user manager is not reachable (%s): checks need `systemctl --user` to work", state)
	} else {
		fmt.Printf("%s %-12s %s\n", paint(green, "ok     "), "user manager", state)
	}
	if left := leftovers(); len(left) > 0 {
		say(yellow, "leftover units from an interrupted check: %s", strings.Join(left, " "))
		say(yellow, "remove them with `systemdlings clean`")
	}
	fmt.Println()
	if missing == 0 {
		say(green, "Everything is installed.")
		return 0
	}
	say(yellow, "%d missing. Chapters whose tools are missing are reported as NO TOOL.", missing)
	return 1
}

func copyTree(src, dst string) error {
	return os.CopyFS(dst, os.DirFS(src))
}
