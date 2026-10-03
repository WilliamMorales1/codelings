package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"syscall"
	"time"
)

const checkTimeout = 90 * time.Second

type Status int

const (
	Pending Status = iota
	Missing        // required tools are not on PATH
	Failed
	Passed
)

type Outcome struct {
	Status  Status
	Output  string
	Missing []string
}

// install maps a tool to the package that provides it; names differ by distro, see README Setup.
var install = map[string]string{
	"bash":            "bash",
	"jq":              "jq",
	"systemctl":       "systemd",
	"systemd-analyze": "systemd",
	"journalctl":      "systemd",
	"systemd-run":     "systemd",
	"systemd-escape":  "systemd",
}

func installHint(tool string) string {
	if c, ok := install[tool]; ok {
		return "install " + c
	}
	return "install `" + tool + "` with your package manager"
}

// runCheck executes the check script with cwd set to dir.
func runCheck(e Exercise, dir string) (bool, string) {
	self, err := os.Executable()
	if err != nil {
		return false, err.Error()
	}
	ctx, cancel := context.WithTimeoutCause(context.Background(), checkTimeout,
		fmt.Errorf("check timed out after %s", checkTimeout))
	defer cancel()
	cmd := exec.CommandContext(ctx, "bash", e.CheckPath())
	cmd.Dir = dir
	cmd.Env = append(os.Environ(),
		"SYSTEMDLINGS_ROOT="+e.root,
		"SYSTEMDLINGS_BIN="+self,
		"EXERCISE_DIR="+dir,
		"SYSTEMDLINGS_LIB="+e.root+"/checks/lib.sh",
		"EXERCISE_NAME="+e.Name,
	)
	// SIGTERM to the whole group first so the check's trap can stop its units;
	// WaitDelay then escalates to SIGKILL and the sweep below mops up.
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	cmd.Cancel = func() error { return syscall.Kill(-cmd.Process.Pid, syscall.SIGTERM) }
	cmd.WaitDelay = 10 * time.Second
	var buf bytes.Buffer
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	err = cmd.Run()
	out := strings.TrimRight(buf.String(), "\n")
	if ctx.Err() != nil {
		out += "\n" + context.Cause(ctx).Error()
		syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
		sweep(e.Name)
	}
	if _, ok := errors.AsType[*exec.ExitError](err); err != nil && !ok {
		out += "\n" + err.Error()
	}
	return err == nil, out
}

func (e Exercise) Check() Outcome {
	// Missing tools first: no point editing an exercise that cannot be checked yet.
	if m := missingTools(e.Requires()); len(m) > 0 {
		return Outcome{Status: Missing, Missing: m}
	}
	ok, out := runCheck(e, e.Dir())
	if ok {
		return Outcome{Status: Passed, Output: out}
	}
	return Outcome{Status: Failed, Output: out}
}
