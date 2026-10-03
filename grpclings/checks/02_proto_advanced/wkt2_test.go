//go:build check

package wkt2

import (
	"testing"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

func stored() *User {
	return &User{Id: "u1", Name: "Ada", Email: "ada@old.example", Address: &Address{Street: "1 Loop St", City: "London"}}
}

func mask(paths ...string) *fieldmaskpb.FieldMask { return &fieldmaskpb.FieldMask{Paths: paths} }

func TestApplyUpdate(t *testing.T) {
	patch := &User{Id: "hacked", Name: "", Email: "ada@new.example", Address: &Address{City: "Paris"}}

	dst := stored()
	if err := ApplyUpdate(dst, patch, mask("email")); err != nil {
		t.Fatalf("mask [email]: %v", err)
	}
	want := stored()
	want.Email = "ada@new.example"
	if !proto.Equal(dst, want) {
		t.Errorf("mask [email]: got %v, want %v", dst, want)
	}

	dst = stored()
	if err := ApplyUpdate(dst, patch, mask("name", "address")); err != nil {
		t.Fatalf("mask [name address]: %v", err)
	}
	if dst.GetName() != "" {
		t.Errorf("name is in the mask and unset in src, so it should be cleared; got %q", dst.GetName())
	}
	if dst.GetAddress().GetCity() != "Paris" || dst.GetAddress().GetStreet() != "" {
		t.Errorf("address should be replaced as a whole, got %v", dst.GetAddress())
	}
	patch.Address.City = "Rome"
	if dst.GetAddress().GetCity() != "Paris" {
		t.Error("dst.Address shares memory with src.Address: clone it")
	}
	if dst.GetId() != "u1" || dst.GetEmail() != "ada@old.example" {
		t.Errorf("fields outside the mask changed: %v", dst)
	}

	for _, bad := range [][]string{{"phone"}, {"id"}} {
		dst = stored()
		if err := ApplyUpdate(dst, patch, mask(bad...)); err == nil {
			t.Errorf("mask %v should be rejected", bad)
		}
		if !proto.Equal(dst, stored()) && bad[0] == "phone" {
			t.Errorf("an invalid mask must leave dst alone, got %v", dst)
		}
	}
}
