package main

import (
	"bufio"
	"cmp"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"unicode"
)

// Exercise is one directory under exercises/, discovered through its check script.
type Exercise struct {
	Chapter string
	Name    string
	root    string
}

func (e Exercise) ID() string  { return e.Chapter + "/" + e.Name }
func (e Exercise) Rel() string { return filepath.Join("exercises", e.Chapter, e.Name) }
func (e Exercise) Dir() string { return filepath.Join(e.root, e.Rel()) }
func (e Exercise) SolutionDir() string {
	return filepath.Join(e.root, "solutions", e.Chapter, e.Name)
}
func (e Exercise) TemplateDir() string {
	return filepath.Join(e.root, ".templates", e.Chapter, e.Name)
}
func (e Exercise) CheckPath() string {
	return filepath.Join(e.root, "checks", e.Chapter, e.Name+".sh")
}

func findRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	for {
		if st, err := os.Stat(filepath.Join(dir, "exercises")); err == nil && st.IsDir() {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", errors.New("could not find an `exercises/` directory; run opslings from inside the course")
		}
		dir = parent
	}
}

// naturalCompare orders "docker2" before "docker10".
func naturalCompare(a, b string) int {
	for a != "" && b != "" {
		da, db := unicode.IsDigit(rune(a[0])), unicode.IsDigit(rune(b[0]))
		if da && db {
			na, ra := splitDigits(a)
			nb, rb := splitDigits(b)
			if c := cmp.Compare(na, nb); c != 0 {
				return c
			}
			a, b = ra, rb
			continue
		}
		if a[0] != b[0] {
			return cmp.Compare(a[0], b[0])
		}
		a, b = a[1:], b[1:]
	}
	return cmp.Compare(len(a), len(b))
}

func splitDigits(s string) (int, string) {
	i := 0
	for i < len(s) && unicode.IsDigit(rune(s[i])) {
		i++
	}
	n, _ := strconv.Atoi(s[:i])
	return n, s[i:]
}

func discover(root string) ([]Exercise, error) {
	chapters, err := os.ReadDir(filepath.Join(root, "checks"))
	if err != nil {
		return nil, err
	}
	var out []Exercise
	for _, ch := range chapters {
		if !ch.IsDir() {
			continue
		}
		files, err := os.ReadDir(filepath.Join(root, "checks", ch.Name()))
		if err != nil {
			return nil, err
		}
		var names []string
		for _, f := range files {
			if name, ok := strings.CutSuffix(f.Name(), ".sh"); ok && !f.IsDir() {
				names = append(names, name)
			}
		}
		slices.SortFunc(names, naturalCompare)
		for _, n := range names {
			out = append(out, Exercise{Chapter: ch.Name(), Name: n, root: root})
		}
	}
	return out, nil
}

func find(exs []Exercise, needle string) (Exercise, error) {
	needle = strings.TrimSuffix(strings.TrimPrefix(filepath.ToSlash(needle), "exercises/"), "/")
	for _, e := range exs {
		if e.Name == needle || e.ID() == needle {
			return e, nil
		}
	}
	return Exercise{}, fmt.Errorf("no exercise named `%s` (try `opslings list`)", needle)
}

// files lists every regular file of a directory tree, sorted.
func files(dir string) []string {
	var out []string
	filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
		if err == nil && d.Type().IsRegular() {
			out = append(out, p)
		}
		return nil
	})
	slices.Sort(out)
	return out
}

// Stamp is a cheap change token over the exercise's files: path, mtime and size.
func (e Exercise) Stamp() string {
	var sb strings.Builder
	for _, f := range files(e.Dir()) {
		if st, err := os.Stat(f); err == nil {
			fmt.Fprintf(&sb, "%s:%d:%d;", f, st.ModTime().UnixNano(), st.Size())
		}
	}
	return sb.String()
}

// header returns the leading comment lines of the check script.
func (e Exercise) header() []string {
	f, err := os.Open(e.CheckPath())
	if err != nil {
		return nil
	}
	defer f.Close()
	var lines []string
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		lines = append(lines, sc.Text())
	}
	return lines
}

// Requires lists the external tools named on the check's `# REQUIRES:` line.
func (e Exercise) Requires() []string {
	for _, l := range e.header() {
		if rest, ok := strings.CutPrefix(l, "# REQUIRES:"); ok {
			return strings.Fields(rest)
		}
	}
	return nil
}

func (e Exercise) Hint() string {
	var out []string
	in := false
	for _, l := range e.header() {
		if !in {
			in = strings.TrimSpace(l) == "# HINT"
			continue
		}
		body, ok := strings.CutPrefix(l, "#")
		if !ok {
			break
		}
		out = append(out, strings.TrimPrefix(body, " "))
	}
	return strings.TrimSpace(strings.Join(out, "\n"))
}

func missingTools(tools []string) []string {
	var missing []string
	for _, t := range tools {
		if _, err := exec.LookPath(t); err != nil {
			missing = append(missing, t)
		}
	}
	return missing
}
