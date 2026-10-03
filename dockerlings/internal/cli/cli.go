package cli

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/furkan/dockerlings/internal/exercises"
	"github.com/furkan/dockerlings/internal/progress"
)

// Course bundles what every command needs.
type Course struct {
	Exercises []exercises.Exercise
	Progress  *progress.Progress
}

func (c Course) pick(name string) (exercises.Exercise, bool) {
	if name == "" {
		for _, e := range c.Exercises {
			if !c.Progress.IsCompleted(e.ID) {
				return e, true
			}
		}
		say(green, "Every exercise is already done.")
		return exercises.Exercise{}, false
	}
	e, err := exercises.Find(c.Exercises, name)
	if err != nil {
		say(red, "%v", err)
		return exercises.Exercise{}, false
	}
	return e, true
}

func label(e exercises.Exercise) string {
	return e.ID + " (" + e.Title + ")"
}

// check runs one exercise, records a pass, and prints the outcome.
func (c Course) check(e exercises.Exercise) bool {
	if e.DependsOn != "" && !c.Progress.IsCompleted(e.DependsOn) {
		say(yellow, "! %s is locked: finish %s first.", label(e), e.DependsOn)
		return false
	}
	ok, out := e.Check()
	if ok {
		say(green, "v %s passes!", label(e))
		indent(out)
		c.Progress.Add(e.ID)
		if err := c.Progress.Save(); err != nil {
			say(red, "could not save progress: %v", err)
		}
		return true
	}
	say(red, "x %s fails.", label(e))
	fmt.Println("  File: " + FileLink(e.MainFile()))
	indent(out)
	fmt.Println()
	fmt.Println("  Stuck? `dockerlings hint " + e.ID + "`")
	return false
}

// Verify checks unfinished exercises in order and stops at the first one that fails.
func (c Course) Verify() int {
	for i, e := range c.Exercises {
		if c.Progress.IsCompleted(e.ID) {
			continue
		}
		fmt.Println(progressBar(i, len(c.Exercises)))
		fmt.Println()
		if !c.check(e) {
			return 1
		}
	}
	fmt.Println(progressBar(len(c.Exercises), len(c.Exercises)))
	say(green, "All %d exercises complete. Ship it.", len(c.Exercises))
	return 0
}

func (c Course) Run(name string) int {
	e, ok := c.pick(name)
	if !ok {
		return 1
	}
	if c.check(e) {
		return 0
	}
	return 1
}

func (c Course) Hint(name string) int {
	e, ok := c.pick(name)
	if !ok {
		return 1
	}
	h, err := exercises.LoadFileContent(e.ID, "hint.md")
	if err != nil {
		say(red, "%v", err)
		return 1
	}
	say(bold, "%s", label(e))
	say(cyan, "Hint:")
	indent(h)
	return 0
}

func (c Course) List() int {
	done := 0
	for _, e := range c.Exercises {
		var l string
		switch {
		case c.Progress.IsCompleted(e.ID):
			l = paint(green, "DONE   ")
			done++
		case e.DependsOn != "" && !c.Progress.IsCompleted(e.DependsOn):
			l = paint(dim, "LOCKED ")
		default:
			l = paint(yellow, "PENDING")
		}
		fmt.Printf("%s  %-8s %-32s %s\n", l, e.ID, e.Title, FileLink(e.MainFile()))
	}
	fmt.Println()
	fmt.Println(progressBar(done, len(c.Exercises)))
	return 0
}

func (c Course) Reset(name string) int {
	if name == "" {
		say(red, "which exercise? (try `dockerlings list`)")
		return 2
	}
	e, ok := c.pick(name)
	if !ok {
		return 1
	}
	if err := e.Reset(); err != nil {
		say(red, "%v", err)
		return 1
	}
	c.Progress.Remove(e.ID)
	if err := c.Progress.Save(); err != nil {
		say(red, "could not save progress: %v", err)
	}
	say(yellow, "reset %s to its original state (containers, volumes and networks it created are left alone)", e.ID)
	return 0
}

var install = map[string]string{
	"bash":   "install bash",
	"curl":   "install curl",
	"docker": "install Docker with buildx (https://docs.docker.com/engine/install/), then add yourself to the docker group",
}

// Doctor reports the tools the check scripts need, and whether the daemon and compose plugin answer.
func Doctor() int {
	missing := 0
	for _, t := range []string{"bash", "curl", "docker"} {
		if p, err := exec.LookPath(t); err == nil {
			fmt.Printf("%s %-16s %s\n", paint(green, "ok     "), t, p)
		} else {
			missing++
			fmt.Printf("%s %-16s %s\n", paint(red, "missing"), t, install[t])
		}
	}
	if _, err := exec.LookPath("docker"); err == nil {
		if err := exec.Command("docker", "info").Run(); err != nil {
			missing++
			fmt.Printf("%s %-16s %s\n", paint(red, "down   "), "docker daemon",
				"sudo systemctl start docker.socket, and be in the docker group (log out and back in after usermod)")
		} else {
			fmt.Printf("%s %-16s %s\n", paint(green, "ok     "), "docker daemon", "reachable")
		}
		if out, err := exec.Command("docker", "compose", "version", "--short").Output(); err != nil {
			missing++
			fmt.Printf("%s %-16s %s %s\n", paint(red, "missing"), "docker compose", "install the docker compose plugin", paint(dim, "(core-12..14)"))
		} else {
			fmt.Printf("%s %-16s %s\n", paint(green, "ok     "), "docker compose", strings.TrimSpace(string(out)))
		}
	}
	fmt.Println()
	if missing == 0 {
		say(green, "Everything is installed.")
		return 0
	}
	say(yellow, "%d missing.", missing)
	return 1
}

func init() {
	if fi, err := os.Stdout.Stat(); err == nil && fi.Mode()&os.ModeCharDevice == 0 {
		noColor = true
	}
}
