// attributes1 -- attributes are typed
//
// Attribute values are not just strings: they can be bool, int64, float64,
// string, and slices of those. Backends keep the type, so a numeric
// attribute can be summed, compared (cart.total > 100) and graphed, while
// the string "104.50" can only be matched character by character.
//
// Task: RecordCart flattens everything to strings. Use the right
// constructor from go.opentelemetry.io/otel/attribute for each value:
//   cart.items        int      number of items
//   cart.total        float64  the total
//   cart.coupon_used  bool     whether a coupon was applied
//   cart.skus         []string the SKUs, in order
//

package attributes1

import (
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

type Item struct {
	SKU   string
	Price float64
}

type Cart struct {
	Items  []Item
	Coupon string
}

func (c Cart) Total() float64 {
	var sum float64
	for _, it := range c.Items {
		sum += it.Price
	}
	return sum
}

// RecordCart describes the cart on span.
func RecordCart(span trace.Span, c Cart) {
	skus := make([]string, 0, len(c.Items))
	for _, it := range c.Items {
		skus = append(skus, it.SKU)
	}
	span.SetAttributes(
		attribute.Int("cart.items", len(c.Items)),
		attribute.Float64("cart.total", c.Total()),
		attribute.Bool("cart.coupon_used", c.Coupon != ""),
		attribute.StringSlice("cart.skus", skus),
	)
}
