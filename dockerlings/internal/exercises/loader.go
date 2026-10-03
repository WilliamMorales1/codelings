package exercises

import (
	"fmt"
	"os"
	"path/filepath"
)

// LoadFileContent reads the content of a specific file (e.g., "prompt.md")
// for a given exercise ID.
func LoadFileContent(exerciseID, fileName string) (string, error) {
	// Construct the full path to the file.
	path := filepath.Join("exercises", exerciseID, fileName)

	// Read the raw bytes from the file.
	content, err := os.ReadFile(path)
	if err != nil {
		// If the file doesn't exist, return a user-friendly error.
		if os.IsNotExist(err) {
			return "", fmt.Errorf("%s not found for exercise %s", fileName, exerciseID)
		}
		// For any other read errors.
		return "", fmt.Errorf("could not read %s: %w", path, err)
	}

	// Convert the byte slice to a string and return it.
	return string(content), nil
}
