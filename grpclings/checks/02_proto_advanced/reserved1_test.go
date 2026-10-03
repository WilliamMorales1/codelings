//go:build check

package reserved1

import (
	"testing"

	"google.golang.org/protobuf/encoding/protowire"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	"grpclings/internal/check"
)

func TestReserved(t *testing.T) {
	md := check.Message(t, "crm.v1.Customer")
	check.Scalar(t, md, "nickname", 5, protoreflect.StringKind, protoreflect.Optional)
	if !md.ReservedRanges().Has(3) {
		t.Error("field number 3 is not reserved")
	}
	if !md.ReservedNames().Has("email") {
		t.Error(`the name "email" is not reserved`)
	}

	// An old client sends field 3 = an email address.
	var old []byte
	old = protowire.AppendTag(old, 1, protowire.BytesType)
	old = protowire.AppendString(old, "c-42")
	old = protowire.AppendTag(old, 3, protowire.BytesType)
	old = protowire.AppendString(old, "ada@example.com")
	var c Customer
	if err := proto.Unmarshal(old, &c); err != nil {
		t.Fatal(err)
	}
	if c.GetNickname() != "" {
		t.Errorf("an old client's email was read as nickname %q", c.GetNickname())
	}
}
