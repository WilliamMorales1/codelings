//go:build check

package protoapi1

import (
	"testing"

	"google.golang.org/protobuf/proto"
)

func TestSameConfig(t *testing.T) {
	a := &Config{Service: "api", Replicas: 3, Tags: []string{}}
	b := &Config{Service: "api", Replicas: 3}
	proto.Marshal(a) // caches a's size inside a
	if !SameConfig(a, b) {
		t.Error("SameConfig: an empty tags list and no tags list are the same config")
	}
	b.Replicas = 4
	if SameConfig(a, b) {
		t.Error("SameConfig: 3 and 4 replicas are different configs")
	}
}

func TestWithDefaults(t *testing.T) {
	orig := &Config{Service: "api", Limits: &Limits{MemoryMib: 256}, Tags: []string{"blue"}}
	keep := proto.CloneOf(orig)
	got := WithDefaults(orig)
	if got.GetReplicas() != 2 || got.GetLimits().GetCpuMillis() != 500 || got.GetLimits().GetMemoryMib() != 256 {
		t.Errorf("WithDefaults = %v", got)
	}
	if !proto.Equal(orig, keep) {
		t.Errorf("WithDefaults modified its argument: now %v, was %v", orig, keep)
	}
	got.Tags[0] = "green"
	if orig.Tags[0] != "blue" {
		t.Error("the copy shares its tags slice with the original")
	}
}
