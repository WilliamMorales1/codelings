// protoapi1: proto.Equal and proto.Clone
//
// Generated messages carry hidden internal state (a cached size, unknown
// fields, a no-copy marker), and they are full of pointers. So:
//   - `==` compares pointers, and reflect.DeepEqual also compares the hidden
//     state and treats a nil slice differently from an empty one. Use
//     proto.Equal(a, b).
//   - `c := *m` copies the hidden state and SHARES every nested message and
//     slice with m. Use proto.Clone(m) (untyped) or proto.CloneOf(m) (generic).
//
// Task: fix both functions. Neither may modify its arguments.
package protoapi1

import "google.golang.org/protobuf/proto"

// SameConfig reports whether two configs mean the same thing.
func SameConfig(a, b *Config) bool {
	return proto.Equal(a, b)
}

// WithDefaults returns a copy of c with defaults filled in: 2 replicas and
// 500m CPU when they are unset. c itself stays as it was.
func WithDefaults(c *Config) *Config {
	out := proto.CloneOf(c)
	if out.Replicas == 0 {
		out.Replicas = 2
	}
	if out.Limits == nil {
		out.Limits = &Limits{}
	}
	if out.Limits.CpuMillis == 0 {
		out.Limits.CpuMillis = 500
	}
	return out
}
