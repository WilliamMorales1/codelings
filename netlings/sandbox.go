package main

import (
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// cmdSandbox runs the exercise's check in interactive mode: the check builds
// its starting topology, then sandbox_here (checks/lib.sh) hands over a shell.
func cmdSandbox(root string, exs []Exercise, name string) int {
	self, err := os.Executable()
	if err != nil {
		say(red, "%v", err)
		return 1
	}
	script := filepath.Join(root, "checks", "sandbox.sh")
	dir, _ := os.Getwd()
	exName := "sandbox"
	if name != "" {
		e, err := find(exs, name)
		if err != nil {
			say(red, "%v", err)
			return 2
		}
		b, err := os.ReadFile(e.CheckPath())
		if err != nil {
			say(red, "%v", err)
			return 1
		}
		if !strings.Contains(string(b), "sandbox_here") {
			say(yellow, "%s has no network to play in (it is a read-the-output exercise).", e.ID())
			say(yellow, "Opening an empty sandbox instead.")
		} else {
			script = e.CheckPath()
			exName = e.Name
		}
		dir = e.Dir()
	}
	cmd := exec.Command("bash", script)
	cmd.Dir = dir
	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
	cmd.Env = append(os.Environ(),
		"NETLINGS_ROOT="+root,
		"NETLINGS_BIN="+self,
		"EXERCISE_DIR="+dir,
		"EXERCISE_NAME="+exName,
		"NETLINGS_INTERACTIVE=1",
	)
	if err := cmd.Run(); err != nil {
		if ee, ok := errors.AsType[*exec.ExitError](err); ok {
			return ee.ExitCode()
		}
		say(red, "%v", err)
		return 1
	}
	return 0
}
