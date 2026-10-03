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
	"bash":  "bash",
	"redis": "valkey or redis (Debian/Ubuntu: redis-server)",
	"go":    "go (golang), 1.27+",
}

// redisPairs are the server/cli pairs a check may use, Valkey first because it is in Arch's official repos.
var redisPairs = [][2]string{{"valkey-server", "valkey-cli"}, {"redis-server", "redis-cli"}}

// lookRedis finds a server and a matching cli; REDISLINGS_SERVER/REDISLINGS_CLI override the search.
func lookRedis() (server, cli string, err error) {
	if s, c := os.Getenv("REDISLINGS_SERVER"), os.Getenv("REDISLINGS_CLI"); s != "" && c != "" {
		return s, c, nil
	}
	for _, p := range redisPairs {
		s, err1 := exec.LookPath(p[0])
		c, err2 := exec.LookPath(p[1])
		if err1 == nil && err2 == nil {
			return s, c, nil
		}
	}
	return "", "", errors.New("neither valkey-server+valkey-cli nor redis-server+redis-cli is on PATH")
}

// lookTool resolves a `# REQUIRES:` name; "redis" is satisfied by either Valkey or Redis.
func lookTool(t string) (string, error) {
	if t == "redis" {
		s, _, err := lookRedis()
		return s, err
	}
	return exec.LookPath(t)
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
		"REDISLINGS_ROOT="+e.root,
		"REDISLINGS_BIN="+self,
		"EXERCISE_DIR="+dir,
		"REDISLINGS_LIB="+e.root+"/checks/lib.sh",
	)
	if srv, cli, err := lookRedis(); err == nil {
		cmd.Env = append(cmd.Env, "REDIS_SERVER="+srv, "REDIS_CLI_BIN="+cli)
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
	ok, out := runCheck(e, e.Dir())
	if ok {
		return Outcome{Status: Passed, Output: out}
	}
	return Outcome{Status: Failed, Output: out}
}
