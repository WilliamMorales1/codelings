package oneof1

// Describe says how a payment was made:
// "card ending 4242", "transfer from DE89...", "cash", or "unknown" when no method is set.
//
// Generated code for `oneof method` gives Payment a Method field of an
// interface type, with one wrapper struct per member: *Payment_Card,
// *Payment_Iban, *Payment_Cash. GetMethod() returns it.
func Describe(p *Payment) string {
	switch m := p.GetMethod().(type) {
	case *Payment_Card:
		return "card ending " + m.Card.GetLast4()
	// TODO: the other two members.
	default:
		return "unknown"
	}
}
