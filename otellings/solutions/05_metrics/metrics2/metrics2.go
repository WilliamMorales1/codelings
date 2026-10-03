// metrics2 -- counters, units and attributes
//
// A Counter only goes up; backends turn it into a rate ("orders per
// second"). Good instruments have:
//   - a dotted, lowercase name:  orders.placed
//   - a UCUM unit:               "{order}" (curly braces = an annotation
//                                for a plain count), "s", "By", "1"
//   - a description
// and attributes that split the count into a *small* number of series,
// here by payment method.
//
// Task: create the counter with unit "{order}" and a description, and
// record the payment method as the "payment.method" attribute (use
// metric.WithAttributes).
//

package metrics2

import (
	"context"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

type Metrics struct {
	orders metric.Int64Counter
}

// New creates the shop's instruments.
func New(m metric.Meter) (*Metrics, error) {
	orders, err := m.Int64Counter("orders.placed",
		metric.WithUnit("{order}"),
		metric.WithDescription("Orders placed, by payment method."),
	)
	if err != nil {
		return nil, err
	}
	return &Metrics{orders: orders}, nil
}

// OrderPlaced counts one order paid with method ("card", "paypal", ...).
func (x *Metrics) OrderPlaced(ctx context.Context, method string) {
	x.orders.Add(ctx, 1, metric.WithAttributes(attribute.String("payment.method", method)))
}
