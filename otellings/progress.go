package main

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
)

const progressFile = ".otellings-progress.json"

// progress remembers which exercises passed, keyed by their file stamp, so editing a solved exercise re-queues it.
type progress struct {
	path   string
	passed map[string]string
}

var prog = &progress{passed: map[string]string{}}

func loadProgress(root string) *progress {
	p := &progress{path: filepath.Join(root, progressFile), passed: map[string]string{}}
	if b, err := os.ReadFile(p.path); err == nil {
		json.Unmarshal(b, &p.passed)
	}
	return p
}

func (p *progress) Done(e Exercise) bool {
	st, ok := p.passed[e.ID()]
	return ok && st == e.Stamp()
}

// Record notes a pass, or forgets an earlier one when the exercise no longer passes.
func (p *progress) Record(e Exercise, o Outcome) {
	switch o.Status {
	case Passed:
		p.passed[e.ID()] = e.Stamp()
	case Failed:
		delete(p.passed, e.ID())
	default:
		return
	}
	p.save()
}

func (p *progress) Forget(e Exercise) {
	delete(p.passed, e.ID())
	p.save()
}

func (p *progress) save() {
	if p.path == "" {
		return
	}
	b, _ := json.MarshalIndent(p.passed, "", "  ")
	os.WriteFile(p.path, append(b, '\n'), 0o644)
}

// editFile is what the File: line points at: the first file the solution changes, else the directory.
func editFile(e Exercise) (abs, rel string) {
	var first string
	for _, f := range files(e.TemplateDir()) {
		r, _ := filepath.Rel(e.TemplateDir(), f)
		if first == "" {
			first = r
		}
		tmpl, _ := os.ReadFile(f)
		sol, err := os.ReadFile(filepath.Join(e.SolutionDir(), r))
		if err != nil || !bytes.Equal(tmpl, sol) {
			return filepath.Join(e.Dir(), r), filepath.Join(e.Rel(), r)
		}
	}
	if first != "" {
		return filepath.Join(e.Dir(), first), filepath.Join(e.Rel(), first)
	}
	return e.Dir(), e.Rel() + "/"
}
