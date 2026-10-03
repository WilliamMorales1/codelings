package exercises

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"time"
)

const checkTimeout = 5 * time.Minute

// Paths are relative to the project root; main chdirs there before anything else runs.
func (e Exercise) Dir() string         { return filepath.Join("exercises", e.ID) }
func (e Exercise) TemplateDir() string { return filepath.Join(".templates", e.ID) }

// specFiles are the course's own files in an exercise directory, never edited by the learner.
var specFiles = []string{"check.sh", "hint.md", "prompt.md"}

// MainFile is the file the learner most likely edits; exercises that are pure CLI practice point at the prompt.
func (e Exercise) MainFile() string {
	for _, name := range []string{"Dockerfile", "compose.yaml", "compose.yml", "docker-compose.yml", "docker-compose.yaml"} {
		for _, dir := range []string{e.Dir(), filepath.Join(e.Dir(), "app")} {
			if p := filepath.Join(dir, name); fileExists(p) {
				return p
			}
		}
	}
	if m, _ := filepath.Glob(filepath.Join(e.Dir(), "run-*.sh")); len(m) > 0 {
		return m[0]
	}
	return filepath.Join(e.Dir(), "prompt.md")
}

func fileExists(p string) bool {
	st, err := os.Stat(p)
	return err == nil && st.Mode().IsRegular()
}

// Stamp is a cheap change token over the learner-editable files: path, mtime and size.
func (e Exercise) Stamp() string {
	var sb strings.Builder
	filepath.WalkDir(e.Dir(), func(p string, d fs.DirEntry, err error) error {
		if err != nil || !d.Type().IsRegular() || slices.Contains(specFiles, d.Name()) {
			return nil
		}
		if st, err := d.Info(); err == nil {
			fmt.Fprintf(&sb, "%s:%d:%d;", p, st.ModTime().UnixNano(), st.Size())
		}
		return nil
	})
	return sb.String()
}

// Check runs the exercise's check.sh from inside its directory and returns its combined output.
func (e Exercise) Check() (bool, string) {
	ctx, cancel := context.WithTimeout(context.Background(), checkTimeout)
	defer cancel()
	cmd := exec.CommandContext(ctx, "bash", "check.sh")
	cmd.Dir = e.Dir()
	out, err := cmd.CombinedOutput()
	text := strings.TrimRight(string(out), "\n")
	if ctx.Err() != nil {
		text += fmt.Sprintf("\ncheck timed out after %s", checkTimeout)
	}
	return err == nil, text
}

// Reset restores the exercise directory from .templates/.
func (e Exercise) Reset() error {
	if _, err := os.Stat(e.TemplateDir()); err != nil {
		return fmt.Errorf("no pristine copy at %s", e.TemplateDir())
	}
	if err := os.RemoveAll(e.Dir()); err != nil {
		return err
	}
	return os.CopyFS(e.Dir(), os.DirFS(e.TemplateDir()))
}

// Find looks an exercise up by id ("core-03") or by its directory path.
func Find(exs []Exercise, needle string) (Exercise, error) {
	needle = strings.TrimSuffix(strings.TrimPrefix(filepath.ToSlash(needle), "exercises/"), "/")
	for _, e := range exs {
		if e.ID == needle {
			return e, nil
		}
	}
	return Exercise{}, fmt.Errorf("no exercise named `%s` (try `dockerlings list`)", needle)
}
