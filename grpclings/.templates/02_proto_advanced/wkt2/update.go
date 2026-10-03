package wkt2

import (
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

// ApplyUpdate copies the fields named in mask from src into dst.
//
// Rules:
//   - a mask that does not fit User (mask.IsValid(dst) is false, e.g. "phone")
//     is an error, and dst is left alone;
//   - "name", "email" and "address" may be updated; "id" may not (error);
//   - copying an unset field clears it in dst;
//   - dst must not end up sharing the nested Address with src.
//
// The code below is a classic bug: it ignores the mask entirely.
func ApplyUpdate(dst, src *User, mask *fieldmaskpb.FieldMask) error {
	proto.Merge(dst, src)
	return nil
}
