package oneof1

// Describe says how a payment was made:
// "card ending 4242", "transfer from DE89...", "cash", or "unknown" when no method is set.
func Describe(p *Payment) string {
	switch m := p.GetMethod().(type) {
	case *Payment_Card:
		return "card ending " + m.Card.GetLast4()
	case *Payment_Iban:
		return "transfer from " + m.Iban
	case *Payment_Cash:
		return "cash"
	default:
		return "unknown"
	}
}
