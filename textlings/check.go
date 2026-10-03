package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

const checkTimeout = 20 * time.Second

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
	"bash":    "bash",
	"diff":    "diffutils",
	"jq":      "jq",
	"gawk":    "gawk",
	"cmp":     "diffutils",
	"sed":     "sed",
	"sort":    "coreutils",
	"uniq":    "coreutils",
	"head":    "coreutils",
	"timeout": "coreutils",
	"nawk":    "nawk (Debian: original-awk; optional: verify-all.sh re-checks the POSIX awk solutions with it)",
}

func installHint(tool string) string {
	if c, ok := install[tool]; ok {
		return "install " + c
	}
	return "install `" + tool + "` with your package manager"
}

// runCheck executes the check script with cwd set to dir.
func runCheck(e Exercise, dir string) (bool, string) {
	ctx, cancel := context.WithTimeoutCause(context.Background(), checkTimeout,
		fmt.Errorf("check timed out after %s", checkTimeout))
	defer cancel()
	cmd := exec.CommandContext(ctx, "bash", e.CheckPath())
	cmd.Dir = dir
	cmd.Env = append(os.Environ(),
		"TEXTLINGS_ROOT="+e.root,
		"EXERCISE_DIR="+dir,
		"EXERCISE_NAME="+e.Name,
		"FIX="+filepath.Join(e.root, "checks", e.Chapter, "fixtures", e.Name),
		"TEXTLINGS_LIB="+e.root+"/checks/lib.sh",
	)
	// A process group lets the timeout also kill whatever a hung pipeline spawned.
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	cmd.Cancel = func() error { return syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL) }
	cmd.WaitDelay = 5 * time.Second
	var buf bytes.Buffer
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	err := cmd.Run()
	out := strings.TrimRight(buf.String(), "\n")
	if ctx.Err() != nil {
		out += "\n" + context.Cause(ctx).Error()
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
