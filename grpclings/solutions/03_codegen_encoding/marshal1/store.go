// marshal1: binary encoding with proto.Marshal
//
// Generated structs look like ordinary Go structs, so encoding/json "works" on
// them. But that is not protobuf: it writes JSON with Go field names, ignores
// field numbers, and cannot be read by any other protobuf implementation. The
// binary wire format comes from google.golang.org/protobuf/proto:
//
//	proto.Marshal(m) ([]byte, error)      proto.Unmarshal(b, m) error
//
// Task: store the todo list in the protobuf binary format. Another program
// (the check) reads the file with proto.Unmarshal.
package marshal1

import (
	"fmt"
	"os"

	"google.golang.org/protobuf/proto"
)

// Save writes list to path in the protobuf binary format.
func Save(path string, list *TodoList) error {
	b, err := proto.Marshal(list)
	if err != nil {
		return fmt.Errorf("encode todo list: %w", err)
	}
	return os.WriteFile(path, b, 0o644)
}

// Load reads a list written by Save.
func Load(path string) (*TodoList, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	list := &TodoList{}
	if err := proto.Unmarshal(b, list); err != nil {
		return nil, fmt.Errorf("decode %s: %w", path, err)
	}
	return list, nil
}
