//go:build check

package optional1

import (
	"testing"

	"google.golang.org/protobuf/proto"
	"grpclings/internal/check"
)

func TestPresence(t *testing.T) {
	fd := check.Field(t, check.Message(t, "prefs.v1.Settings"), "volume")
	if !fd.HasPresence() {
		t.Fatal("volume has no presence: mark it `optional`")
	}
	cases := []struct {
		s    *Settings
		want int32
	}{
		{&Settings{UserId: "u1"}, 50},
		{&Settings{UserId: "u2", Volume: proto.Int32(0)}, 0},
		{&Settings{UserId: "u3", Volume: proto.Int32(80)}, 80},
	}
	for _, c := range cases {
		// Round-trip through the wire format: presence must survive encoding.
		b, err := proto.Marshal(c.s)
		if err != nil {
			t.Fatal(err)
		}
		var got Settings
		if err := proto.Unmarshal(b, &got); err != nil {
			t.Fatal(err)
		}
		if v := EffectiveVolume(&got); v != c.want {
			t.Errorf("EffectiveVolume(%v) = %d, want %d", c.s, v, c.want)
		}
	}
}
