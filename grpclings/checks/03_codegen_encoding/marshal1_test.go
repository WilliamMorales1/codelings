//go:build check

package marshal1

import (
	"os"
	"path/filepath"
	"testing"

	"google.golang.org/protobuf/proto"
)

func TestSaveLoad(t *testing.T) {
	list := &TodoList{Owner: "ada", Tasks: []*Task{{Title: "write schema", Done: true}, {Title: "ship it"}}}
	path := filepath.Join(t.TempDir(), "todo.bin")
	if err := Save(path, list); err != nil {
		t.Fatalf("Save: %v", err)
	}
	b, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	var other TodoList
	if err := proto.Unmarshal(b, &other); err != nil || !proto.Equal(&other, list) {
		t.Fatalf("the file is not a protobuf-encoded TodoList (first bytes %q)", b[:min(len(b), 16)])
	}
	back, err := Load(path)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if !proto.Equal(back, list) {
		t.Errorf("Load returned %v, want %v", back, list)
	}
	os.WriteFile(path, []byte{0x0a, 0xff}, 0o644)
	if _, err := Load(path); err == nil {
		t.Error("Load of a truncated file should return an error")
	}
}
