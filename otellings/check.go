package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
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
	"go":              "go (golang), 1.27+",
	"otelcol-contrib": "otelcol-contrib 0.162.0 from https://github.com/open-telemetry/opentelemetry-collector-releases/releases into ~/.local/bin",
}

func installHint(tool string) string {
	if c, ok := install[tool]; ok {
		return "install " + c
	}
	return "install `" + tool + "` with your package manager"
}

// workDir is where a check runs: a throwaway Go module per exercise and variant. It is
// kept between runs so the Go build and test caches make re-checks nearly free.
func workDir(e Exercise, variant string) string {
	return filepath.Join(e.root, ".work", variant, e.Chapter, e.Name)
}

// prepare mirrors the course's go.mod, the shared checkutil package, the exercise files
// and the hidden check into dst, rewriting only files whose content changed.
func prepare(e Exercise, src, dst string) error {
	want := map[string][]byte{}
	for _, f := range []string{"go.mod", "go.sum"} {
		b, err := os.ReadFile(filepath.Join(e.root, f))
		if err != nil {
			return err
		}
		want[f] = b
	}
	add := func(from, to string) error {
		return filepath.WalkDir(from, func(p string, d fs.DirEntry, err error) error {
			if err != nil || !d.Type().IsRegular() {
				return err
			}
			b, err := os.ReadFile(p)
			if err != nil {
				return err
			}
			rel, _ := filepath.Rel(from, p)
			want[filepath.Join(to, rel)] = b
			return nil
		})
	}
	if err := add(filepath.Join(e.root, "checks", "checkutil"), filepath.Join("checks", "checkutil")); err != nil {
		return err
	}
	if err := add(src, "ex"); err != nil {
		return err
	}
	chk, err := os.ReadFile(e.CheckPath())
	if err != nil {
		return err
	}
	want[filepath.Join("ex", "zz_check_test.go")] = chk

	// Drop files that no longer exist in the source (renamed or deleted by the learner).
	filepath.WalkDir(dst, func(p string, d fs.DirEntry, err error) error {
		if err == nil && d.Type().IsRegular() {
			rel, _ := filepath.Rel(dst, p)
			if _, ok := want[rel]; !ok {
				os.Remove(p)
			}
		}
		return nil
	})
	for rel, b := range want {
		p := filepath.Join(dst, rel)
		if old, err := os.ReadFile(p); err == nil && bytes.Equal(old, b) {
			continue
		}
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			return err
		}
		if err := os.WriteFile(p, b, 0o644); err != nil {
			return err
		}
	}
	return nil
}

// runCheck copies src into its work module and runs `go test` there.
func runCheck(e Exercise, src, variant string) (bool, string) {
	dir := workDir(e, variant)
	if err := prepare(e, src, dir); err != nil {
		return false, err.Error()
	}
	ctx, cancel := context.WithTimeoutCause(context.Background(), checkTimeout,
		fmt.Errorf("check timed out after %s", checkTimeout))
	defer cancel()
	cmd := exec.CommandContext(ctx, "go", "test", "-tags", "otellings_check", "./ex")
	cmd.Dir = dir
	cmd.Env = append(os.Environ(), "GOWORK=off")
	// A process group lets the timeout take down a collector the test started too.
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	cmd.Cancel = func() error { return syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL) }
	cmd.WaitDelay = 5 * time.Second
	var buf bytes.Buffer
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	err := cmd.Run()
	out := tidyOutput(buf.String(), e.Rel()+"/")
	if ctx.Err() != nil {
		out += "\n" + context.Cause(ctx).Error()
	}
	if _, ok := errors.AsType[*exec.ExitError](err); err != nil && !ok {
		out += "\n" + err.Error()
	}
	return err == nil, out
}

// tidyOutput drops go test's bookkeeping lines and points file:line references at the exercise.
func tidyOutput(s, rel string) string {
	var keep []string
	for l := range strings.SplitSeq(strings.TrimRight(s, "\n"), "\n") {
		t := strings.TrimSpace(l)
		switch {
		case t == "FAIL", t == "PASS", strings.HasPrefix(t, "ok "), strings.HasPrefix(t, "FAIL\totellings/"),
			strings.HasPrefix(t, "# otellings/"), strings.HasPrefix(t, "--- FAIL"), strings.HasPrefix(t, "=== RUN"):
			continue
		}
		l = strings.ReplaceAll(strings.ReplaceAll(l, "ex/zz_check_test.go", "check"), "zz_check_test.go", "check")
		if rest, ok := strings.CutPrefix(l, "ex/"); ok {
			l = rel + rest
		}
		keep = append(keep, l)
	}
	return strings.Join(keep, "\n")
}

func (e Exercise) Check() Outcome {
	// Missing tools first: no point editing an exercise that cannot be checked yet.
	if m := missingTools(e.Requires()); len(m) > 0 {
		return Outcome{Status: Missing, Missing: m}
	}
	ok, out := runCheck(e, e.Dir(), "learner")
	if ok {
		return Outcome{Status: Passed}
	}
	return Outcome{Status: Failed, Output: out}
}
