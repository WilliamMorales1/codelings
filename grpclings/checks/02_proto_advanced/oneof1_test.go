//go:build check

package oneof1

import (
	"testing"

	"grpclings/internal/check"
)

func TestOneof(t *testing.T) {
	md := check.Message(t, "billing.v1.Payment")
	for _, name := range []string{"card", "iban", "cash"} {
		fd := check.Field(t, md, name)
		if o := fd.ContainingOneof(); o == nil || o.Name() != "method" {
			t.Errorf("field %s should be a member of `oneof method`", name)
		}
	}
	cases := []struct {
		p    *Payment
		want string
	}{
		{&Payment{Method: &Payment_Card{Card: &Card{Last4: "4242"}}}, "card ending 4242"},
		{&Payment{Method: &Payment_Iban{Iban: "DE89370400440532013000"}}, "transfer from DE89370400440532013000"},
		{&Payment{Method: &Payment_Cash{Cash: true}}, "cash"},
		{&Payment{}, "unknown"},
		{nil, "unknown"},
	}
	for _, c := range cases {
		if got := Describe(c.p); got != c.want {
			t.Errorf("Describe(%v) = %q, want %q", c.p, got, c.want)
		}
	}
}
