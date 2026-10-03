//go:build otellings_check

/* HINT
Put `defer span.End()` on the line right after tr.Start, and remove the
explicit span.End() at the bottom (ending twice is harmless, but pointless).
*/

package tracing3

import (
	"testing"

	"otellings/checks/checkutil"
)

func TestEveryPathEndsTheSpan(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	tr := tp.Tracer("check")
	for _, id := range []string{"", "bad-1", "ord-42"} {
		before := len(sr.Ended())
		err := ProcessOrder(t.Context(), tr, id)
		if (err == nil) != (id == "ord-42") {
			t.Errorf("ProcessOrder(%q) error = %v", id, err)
		}
		ended := 0
		for _, s := range sr.Ended()[before:] {
			if s.Name() == "process-order" {
				ended++
			}
		}
		if ended != 1 {
			t.Errorf("ProcessOrder(%q) left its process-order span open", id)
		}
	}
	if n := len(sr.Started()) - len(sr.Ended()); n != 0 {
		t.Errorf("%d spans were started but never ended", n)
	}
}
