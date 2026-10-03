//go:build check

package streams1

import (
	"testing"

	"google.golang.org/grpc"
	"grpclings/internal/check"
)

func texts(lines []*LogLine) []string {
	var out []string
	for _, l := range lines {
		out = append(out, l.GetText())
	}
	return out
}

func TestTail(t *testing.T) {
	srv := &Server{Lines: []*LogLine{
		{Level: "INFO", Text: "boot"}, {Level: "WARN", Text: "disk 80%"},
		{Level: "INFO", Text: "ready"}, {Level: "ERROR", Text: "disk full"},
	}}
	conn := check.Serve(t, func(s *grpc.Server) { RegisterLogServiceServer(s, srv) })
	c := NewLogServiceClient(conn)

	all, err := Collect(t.Context(), c, "")
	if err != nil {
		t.Fatalf("Collect: %v", err)
	}
	if got := texts(all); len(got) != 4 || got[0] != "boot" || got[3] != "disk full" {
		t.Errorf("all lines: got %q", got)
	}
	info, err := Collect(t.Context(), c, "INFO")
	if err != nil {
		t.Fatalf("Collect(INFO): %v", err)
	}
	if got := texts(info); len(got) != 2 || got[0] != "boot" || got[1] != "ready" {
		t.Errorf("INFO lines: got %q, want [boot ready]", got)
	}
	none, err := Collect(t.Context(), c, "DEBUG")
	if err != nil || len(none) != 0 {
		t.Errorf("DEBUG lines: got %v, %v; want none and no error", texts(none), err)
	}
}
