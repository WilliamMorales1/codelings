package wkt1

import "time"

// Expired reports whether the session is over at now. A session with a missing
// or invalid timestamp or TTL counts as expired.
//
// Useful: (*timestamppb.Timestamp).AsTime and .CheckValid,
// (*durationpb.Duration).AsDuration and .CheckValid. CheckValid on a nil
// message returns an error, which is exactly what "missing" should do.
func Expired(s *Session, now time.Time) bool {
	// TODO
	return false
}
