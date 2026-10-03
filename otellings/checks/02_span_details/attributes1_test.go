//go:build otellings_check

/* HINT
attribute.Int, attribute.Float64, attribute.Bool and attribute.StringSlice.
Once nothing is formatted any more, drop the fmt/strconv/strings imports.
*/

package attributes1

import (
	"slices"
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/attribute"
)

func TestTypedAttributes(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	_, span := tp.Tracer("check").Start(t.Context(), "checkout")
	RecordCart(span, Cart{Items: []Item{{"A-1", 99.5}, {"B-2", 5}}, Coupon: "SPRING"})
	span.End()
	attrs := sr.Ended()[0].Attributes()

	want := map[string]attribute.Type{
		"cart.items":       attribute.INT64,
		"cart.total":       attribute.FLOAT64,
		"cart.coupon_used": attribute.BOOL,
		"cart.skus":        attribute.STRINGSLICE,
	}
	for key, typ := range want {
		v, ok := checkutil.Attr(attrs, key)
		if !ok {
			t.Errorf("missing attribute %s", key)
			continue
		}
		if v.Type() != typ {
			t.Errorf("%s has type %s, want %s", key, v.Type(), typ)
		}
	}
	if v, _ := checkutil.Attr(attrs, "cart.items"); v.Type() == attribute.INT64 && v.AsInt64() != 2 {
		t.Errorf("cart.items = %d, want 2", v.AsInt64())
	}
	if v, _ := checkutil.Attr(attrs, "cart.total"); v.Type() == attribute.FLOAT64 && v.AsFloat64() != 104.5 {
		t.Errorf("cart.total = %v, want 104.5", v.AsFloat64())
	}
	if v, _ := checkutil.Attr(attrs, "cart.coupon_used"); v.Type() == attribute.BOOL && !v.AsBool() {
		t.Errorf("cart.coupon_used = false, want true")
	}
	if v, _ := checkutil.Attr(attrs, "cart.skus"); v.Type() == attribute.STRINGSLICE && !slices.Equal(v.AsStringSlice(), []string{"A-1", "B-2"}) {
		t.Errorf("cart.skus = %v", v.AsStringSlice())
	}
}
