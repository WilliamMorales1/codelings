//go:build otellings_check

/* HINT
span.AddEvent("cache.miss", trace.WithAttributes(attribute.String("cache.key", key)))
*/

package events1

import (
	"testing"

	"otellings/checks/checkutil"
)

func TestMissEvent(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	tr := tp.Tracer("check")
	cache := map[string]string{}
	if got := Lookup(t.Context(), tr, cache, "tea"); got != "TEA" {
		t.Fatalf("Lookup = %q", got)
	}
	Lookup(t.Context(), tr, cache, "tea")

	spans := sr.Ended()
	if len(spans) != 2 {
		t.Fatalf("want 2 spans, got %d", len(spans))
	}
	if _, ok := checkutil.Attr(spans[0].Attributes(), "cache.missed"); ok {
		t.Errorf("drop the cache.missed attribute; the event replaces it")
	}
	miss := spans[0].Events()
	if len(miss) != 1 || miss[0].Name != "cache.miss" {
		t.Fatalf("first lookup (a miss) should have exactly one cache.miss event, got %d events", len(miss))
	}
	if v, ok := checkutil.Attr(miss[0].Attributes, "cache.key"); !ok || v.AsString() != "tea" {
		t.Errorf("cache.miss event needs cache.key=tea")
	}
	if n := len(spans[1].Events()); n != 0 {
		t.Errorf("second lookup is a hit and should have no events, got %d", n)
	}
}
