//go:build check

package wkt1

import (
	"testing"
	"time"

	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/known/durationpb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"grpclings/internal/check"
)

func TestSession(t *testing.T) {
	md := check.Message(t, "auth.v1.Session")
	check.MessageField(t, md, "created_at", 2, "google.protobuf.Timestamp", protoreflect.Optional)
	check.MessageField(t, md, "ttl", 3, "google.protobuf.Duration", protoreflect.Optional)
	if md.Fields().ByName("created_unix") != nil {
		t.Error("created_unix should be gone")
	}

	start := time.Date(2026, 9, 29, 12, 0, 0, 0, time.UTC)
	s := &Session{UserId: "ada", CreatedAt: timestamppb.New(start), Ttl: durationpb.New(15 * time.Minute)}
	if Expired(s, start.Add(14*time.Minute)) {
		t.Error("a 15m session is not expired after 14m")
	}
	if !Expired(s, start.Add(15*time.Minute)) {
		t.Error("a 15m session is expired after exactly 15m")
	}
	if !Expired(&Session{UserId: "bob", Ttl: durationpb.New(time.Hour)}, start) {
		t.Error("a session without created_at counts as expired")
	}
	if !Expired(&Session{UserId: "eve", CreatedAt: timestamppb.New(start)}, start) {
		t.Error("a session without ttl counts as expired")
	}

	j, _ := protojson.Marshal(s)
	t.Logf("as JSON: %s", j)
}
