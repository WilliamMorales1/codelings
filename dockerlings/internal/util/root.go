// internal/util/root.go
package util

import (
	"fmt"
	"os"
	"path/filepath"
)

// GetProjectRoot walks up from the working directory to the one holding dockerlings.toml,
// falling back to the directory above the executable (the old bin/dockerlings layout).
func GetProjectRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	for {
		if _, err := os.Stat(filepath.Join(dir, "dockerlings.toml")); err == nil {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			break
		}
		dir = parent
	}

	executablePath, err := os.Executable()
	if err != nil {
		return "", fmt.Errorf("could not get executable path: %w", err)
	}
	root := filepath.Clean(filepath.Join(filepath.Dir(executablePath), ".."))
	if _, err := os.Stat(filepath.Join(root, "dockerlings.toml")); err != nil {
		return "", fmt.Errorf("could not find dockerlings.toml; run dockerlings from inside the repository")
	}
	return root, nil
}
