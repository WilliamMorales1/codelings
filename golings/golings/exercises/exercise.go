package exercises

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// ProgressFile remembers which exercises passed, keyed by file stamp, so editing a solved one re-queues it.
var ProgressFile = ".golings-progress.json"

type Exercise struct {
	Name string
	Path string
	Mode string
	Hint string
}

// TemplatePath is the pristine copy of the exercise that `golings reset` restores.
func (e Exercise) TemplatePath() string {
	return filepath.Join(".templates", strings.TrimPrefix(filepath.ToSlash(e.Path), "exercises/"))
}

// State is Done once the exercise has passed and has not been edited since.
func (e Exercise) State() State {
	if st := stamp(e.Path); st != "" && loadProgress()[e.Name] == st {
		return Done
	}
	return Pending
}

func stamp(path string) string {
	st, err := os.Stat(path)
	if err != nil {
		return ""
	}
	return fmt.Sprintf("%d:%d", st.ModTime().UnixNano(), st.Size())
}

func loadProgress() map[string]string {
	p := map[string]string{}
	if b, err := os.ReadFile(ProgressFile); err == nil {
		json.Unmarshal(b, &p)
	}
	return p
}

func record(e Exercise, passed bool) {
	p := loadProgress()
	if passed {
		p[e.Name] = stamp(e.Path)
	} else {
		delete(p, e.Name)
	}
	b, _ := json.MarshalIndent(p, "", "  ")
	os.WriteFile(ProgressFile, append(b, '\n'), 0o644)
}

type State int

const (
	Pending State = iota + 1
	Done
)

func (s State) String() string {
	return [...]string{"Pending", "Done"}[s-1]
}
