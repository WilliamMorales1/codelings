package main

import (
	"bytes"
	"crypto/sha256"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

// warm downloads modules and compiles gRPC and the codegen plugins once, so the
// first check is not mysteriously slow. A stamp keyed by go.sum skips it later.
func warm(root string, verbose bool) error {
	sum, err := os.ReadFile(filepath.Join(root, "go.sum"))
	if err != nil {
		return err
	}
	cache, err := os.UserCacheDir()
	if err != nil {
		cache = os.TempDir()
	}
	stamp := filepath.Join(cache, "grpclings", fmt.Sprintf("warm-%x", sha256.Sum256(sum))[:len("warm-")+16])
	if _, err := os.Stat(stamp); err == nil && !verbose {
		return nil
	}
	start := time.Now()
	if !verbose {
		say(dim, "First run: downloading Go modules and compiling protobuf, gRPC and the protoc plugins.")
		say(dim, "This happens once and takes a minute or two; later checks take a few seconds.")
	}
	steps := [][]string{
		{"go", "build", "./internal/warm"},
		{"go", "tool", "-n", "protoc-gen-go"},
		{"go", "tool", "-n", "protoc-gen-go-grpc"},
	}
	if _, err := exec.LookPath("buf"); err != nil {
		steps = append(steps, []string{"go", "tool", "-n", "buf"})
	}
	for _, s := range steps {
		cmd := exec.Command(s[0], s[1:]...)
		cmd.Dir = root
		var out bytes.Buffer
		cmd.Stdout, cmd.Stderr = &out, &out
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("%v failed: %v\n%s", s, err, out.String())
		}
	}
	if !verbose {
		say(dim, "Ready (%s).", time.Since(start).Round(time.Second))
	}
	os.MkdirAll(filepath.Dir(stamp), 0o755)
	return os.WriteFile(stamp, nil, 0o644)
}

func goTool(root, name string, args ...string) (string, error) {
	cmd := exec.Command("go", append([]string{"tool", name}, args...)...)
	cmd.Dir = root
	out, err := cmd.CombinedOutput()
	return string(out), err
}
