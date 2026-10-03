//go:build check

package protojson1

import (
	"encoding/json"
	"testing"
	"time"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func TestExport(t *testing.T) {
	ev := &Event{
		EventId:    "e-1",
		ActorEmail: "ada@example.com",
		Severity:   Severity_SEVERITY_ALERT,
		OccurredAt: timestamppb.New(time.Date(2026, 9, 29, 8, 30, 0, 0, time.UTC)),
	}
	b, err := Export(ev)
	if err != nil {
		t.Fatal(err)
	}
	t.Logf("Export wrote: %s", b)
	var got map[string]any
	if err := json.Unmarshal(b, &got); err != nil {
		t.Fatal(err)
	}
	want := map[string]any{
		"event_id":    "e-1",
		"actor_email": "ada@example.com",
		"severity":    "SEVERITY_ALERT",
		"retry_count": float64(0),
		"occurred_at": "2026-09-29T08:30:00Z",
	}
	for k, v := range want {
		if got[k] != v {
			t.Errorf("key %q = %v, want %v", k, got[k], v)
		}
	}
	if len(got) != len(want) {
		t.Errorf("got keys %v, want exactly %d keys", got, len(want))
	}
}

func TestImport(t *testing.T) {
	newer := `{"event_id": "e-2", "severity": "SEVERITY_INFO", "trace_id": "added-in-v2"}`
	ev, err := Import([]byte(newer))
	if err != nil {
		t.Fatalf("Import of JSON from a newer producer: %v", err)
	}
	if !proto.Equal(ev, &Event{EventId: "e-2", Severity: Severity_SEVERITY_INFO}) {
		t.Errorf("Import = %v", ev)
	}
	if _, err := Import([]byte(`{"event_id": 7}`)); err == nil {
		t.Error("Import should still reject JSON with the wrong type for a known field")
	}
}
