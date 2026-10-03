//go:build check

package basics5

import (
	"testing"

	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/descriptorpb"
	"grpclings/internal/check"
)

func TestProduct(t *testing.T) {
	md := check.Message(t, "shop.v1.Product")
	check.MessageField(t, md, "price", 3, "common.v1.Money", protoreflect.Optional)
	f := md.ParentFile()
	if f.Imports().Len() != 1 || f.Imports().Get(0).Path() != "money.proto" {
		t.Errorf(`product.proto should import exactly "money.proto"`)
	}
	opts := f.Options().(*descriptorpb.FileOptions)
	want := "grpclings/exercises/01_proto_basics/basics5;basics5"
	if got := opts.GetGoPackage(); got != want {
		t.Errorf("go_package = %q, want %q", got, want)
	}
	p := &Product{Price: &Money{Currency: "EUR", Units: 1299}}
	if p.GetPrice().GetUnits() != 1299 {
		t.Fatal("Product.Price should be a *Money")
	}
}
