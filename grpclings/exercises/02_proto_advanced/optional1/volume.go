package optional1

const defaultVolume = 50

// EffectiveVolume is the volume to play at: the user's choice, or the default when they made none.
func EffectiveVolume(s *Settings) int32 {
	if s.GetVolume() == 0 {
		return defaultVolume
	}
	return s.GetVolume()
}
