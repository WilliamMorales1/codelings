//go:build otellings_check

/* HINT
Derive new contexts from r.Context(), never from context.Background(),
inside a request. Both the auth middleware and the handler need that fix.
*/

package otelhttp3

import (
	"net/http/httptest"
	"testing"

	"otellings/checks/checkutil"

	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

func TestOneTrace(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	req := httptest.NewRequest("GET", "/orders/7", nil)
	req.Header.Set("X-User", "ada")
	rec := httptest.NewRecorder()
	NewServer(tp).ServeHTTP(rec, req)
	if rec.Body.String() != "order 7 for ada\n" {
		t.Fatalf("response %q, want \"order 7 for ada\"", rec.Body.String())
	}
	var server sdktrace.ReadOnlySpan
	for _, s := range sr.Ended() {
		if s.SpanKind() == trace.SpanKindServer {
			server = s
		}
	}
	if server == nil {
		t.Fatal("no server span")
	}
	load := checkutil.Span(t, sr.Ended(), "orders.load")
	if load.Parent().SpanID() != server.SpanContext().SpanID() {
		t.Errorf("orders.load is not a child of the server span %q", server.Name())
	}
}
