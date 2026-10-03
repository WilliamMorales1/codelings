// Package progress
package progress

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"slices"
)

const (
	progressDir  = ".dockerlings"
	progressFile = "progress.json"
)

type Progress struct {
	CompletedIDs []string `json:"completed_ids"`
}

func getProgressFilePath() (string, error) {
	// TODO: progress file should be created in the user's home directory
	err := os.MkdirAll(progressDir, 0o755)
	if err != nil {
		return "", fmt.Errorf("could not create progress directory: %w", err)
	}
	return filepath.Join(progressDir, progressFile), nil
}

func Load() (*Progress, error) {
	path, err := getProgressFilePath()
	if err != nil {
		return nil, err
	}

	data, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		return &Progress{CompletedIDs: []string{}}, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to read progress file: %w", err)
	}

	var p Progress
	if err := json.Unmarshal(data, &p); err != nil {
		return nil, fmt.Errorf("failed to parse progress file: %w", err)
	}

	return &p, nil
}

func (p *Progress) Save() error {
	path, err := getProgressFilePath()
	if err != nil {
		return err
	}

	data, err := json.MarshalIndent(p, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to encode progress to JSON: %w", err)
	}

	return os.WriteFile(path, data, 0o644)
}

func (p *Progress) IsCompleted(id string) bool {
	for _, completedID := range p.CompletedIDs {
		if completedID == id {
			return true
		}
	}
	return false
}

func (p *Progress) Add(id string) {
	if !p.IsCompleted(id) {
		p.CompletedIDs = append(p.CompletedIDs, id)
	}
}

func (p *Progress) Remove(id string) {
	p.CompletedIDs = slices.DeleteFunc(p.CompletedIDs, func(c string) bool { return c == id })
}
