//go:build otellings_check

/* HINT
  tr.Start(ctx, "GET /users/{id}", trace.WithAttributes(attribute.String("user.id", id)))

attribute is go.opentelemetry.io/otel/attribute.
*/

package tracing4

import (
	"testing"

	"otellings/checks/checkutil"
)

func TestStableNameAndAttribute(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	ids := []string{"8412", "17"}
	for _, id := range ids {
		GetUser(t.Context(), tp.Tracer("check"), id)
	}
	spans := sr.Ended()
	if len(spans) != 2 {
		t.Fatalf("got %d spans, want 2", len(spans))
	}
	for i, s := range spans {
		if s.Name() != "GET /users/{id}" {
			t.Errorf("span name = %q, want \"GET /users/{id}\" for every user", s.Name())
		}
		v, ok := checkutil.Attr(s.Attributes(), "user.id")
		if !ok || v.AsString() != ids[i] {
			t.Errorf("span %d: user.id = %q (present: %v), want %q", i, v.Emit(), ok, ids[i])
		}
	}
}
