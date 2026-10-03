package wkt1

import "time"

// Expired reports whether the session is over at now. A session with a missing
// or invalid timestamp or TTL counts as expired.
func Expired(s *Session, now time.Time) bool {
	if s.GetCreatedAt().CheckValid() != nil || s.GetTtl().CheckValid() != nil {
		return true
	}
	end := s.GetCreatedAt().AsTime().Add(s.GetTtl().AsDuration())
	return !now.Before(end)
}
