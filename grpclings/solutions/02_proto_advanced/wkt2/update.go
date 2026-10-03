package wkt2

import (
	"fmt"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

// ApplyUpdate copies the fields named in mask from src into dst.
func ApplyUpdate(dst, src *User, mask *fieldmaskpb.FieldMask) error {
	if !mask.IsValid(dst) {
		return fmt.Errorf("invalid update_mask %v", mask.GetPaths())
	}
	for _, path := range mask.GetPaths() {
		switch path {
		case "name":
			dst.Name = src.GetName()
		case "email":
			dst.Email = src.GetEmail()
		case "address":
			// Clone so dst does not share the nested message with src.
			dst.Address = proto.CloneOf(src.GetAddress())
		default:
			return fmt.Errorf("update_mask: %q cannot be updated", path)
		}
	}
	return nil
}
