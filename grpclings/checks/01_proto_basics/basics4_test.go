//go:build check

package basics4

import (
	"testing"

	"google.golang.org/protobuf/reflect/protoreflect"
	"grpclings/internal/check"
)

func TestCart(t *testing.T) {
	cart := check.Message(t, "shop.v1.Cart")
	check.Message(t, "shop.v1.Cart.Item")
	check.MessageField(t, cart, "items", 2, "shop.v1.Cart.Item", protoreflect.Repeated)
	check.Scalar(t, cart, "coupon_codes", 3, protoreflect.StringKind, protoreflect.Repeated)
	receipt := check.Message(t, "shop.v1.Receipt")
	check.MessageField(t, receipt, "lines", 2, "shop.v1.Cart.Item", protoreflect.Repeated)

	// In Go a nested message becomes Outer_Inner and a repeated field a slice.
	c := &Cart{Items: []*Cart_Item{{Sku: "tea", Quantity: 2}}, CouponCodes: []string{"WELCOME"}}
	if len(c.GetItems()) != 1 || len(c.GetCouponCodes()) != 1 {
		t.Fatal("repeated fields should be slices")
	}
}
