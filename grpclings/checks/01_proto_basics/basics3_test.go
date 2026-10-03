//go:build check

package basics3

import (
	"testing"

	"google.golang.org/protobuf/reflect/protoreflect"
	"grpclings/internal/check"
)

func wantValues(t *testing.T, name string, want []string) {
	t.Helper()
	ed := check.Enum(t, name)
	if ed.Values().Len() != len(want) {
		t.Errorf("%s has %d values, want %d", name, ed.Values().Len(), len(want))
	}
	for i, w := range want {
		v := ed.Values().ByNumber(protoreflect.EnumNumber(i))
		if v == nil {
			t.Errorf("%s has no value numbered %d (want %s)", name, i, w)
			continue
		}
		if string(v.Name()) != w {
			t.Errorf("%s value %d is %s, want %s", name, i, v.Name(), w)
		}
	}
}

func TestEnums(t *testing.T) {
	wantValues(t, "shop.v1.OrderStatus", []string{"ORDER_STATUS_UNSPECIFIED", "ORDER_STATUS_PENDING", "ORDER_STATUS_SHIPPED", "ORDER_STATUS_DELIVERED"})
	wantValues(t, "shop.v1.PaymentStatus", []string{"PAYMENT_STATUS_UNSPECIFIED", "PAYMENT_STATUS_PENDING", "PAYMENT_STATUS_PAID"})
	if got := (&Order{}).GetStatus(); got != OrderStatus_ORDER_STATUS_UNSPECIFIED {
		t.Errorf("an unset Order.status reads as %v, want ORDER_STATUS_UNSPECIFIED", got)
	}
}
