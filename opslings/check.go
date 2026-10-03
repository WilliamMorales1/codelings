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

const checkTimeout = 180 * time.Second

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
	"bash":        "bash",
	"curl":        "curl",
	"jq":          "jq",
	"yq":          "yq by mikefarah (Arch: go-yq, brew: yq)",
	"docker":      "Docker Engine with compose and buildx (https://docs.docker.com/engine/install/), then add yourself to the docker group",
	"kubeconform": "kubeconform",
	"helm":        "helm",
	"k6":          "k6 (https://github.com/grafana/k6/releases)",
	"promtool":    "prometheus",
	"tofu":        "opentofu",
	"caddy":       "caddy",
	"kind":        "kind",
	"kubectl":     "kubectl",
}

func installHint(tool string) string {
	if c, ok := install[tool]; ok {
		return "install " + c
	}
	return "install `" + tool + "` with your package manager"
}

// runCheck executes the check script with cwd set to dir; selftest tells live-cluster checks to stick to the files.
func runCheck(e Exercise, dir string, selftest bool) (bool, string) {
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
		"OPSLINGS_ROOT="+e.root,
		"OPSLINGS_BIN="+self,
		"EXERCISE_DIR="+dir,
		"OPSLINGS_LIB="+e.root+"/checks/lib.sh",
	)
	if selftest {
		cmd.Env = append(cmd.Env, "OPSLINGS_SELFTEST=1")
	}
	// A process group lets the timeout take down background servers too.
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	cmd.Cancel = func() error { return syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL) }
	cmd.WaitDelay = 5 * time.Second
	var buf bytes.Buffer
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	err = cmd.Run()
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
	ok, out := runCheck(e, e.Dir(), false)
	if ok {
		return Outcome{Status: Passed, Output: out}
	}
	return Outcome{Status: Failed, Output: out}
}
