//go:build otellings_check

/* HINT
ctx := propagation.TraceContext{}.Extract(r.Context(), propagation.HeaderCarrier(r.Header))
*/

package propagation2

import (
	"net/http/httptest"
	"testing"

	"otellings/checks/checkutil"
)

func TestContinuesRemoteTrace(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	req := httptest.NewRequest("GET", "/items", nil)
	req.Header.Set("traceparent", "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01")
	rec := httptest.NewRecorder()
	Handler(tp.Tracer("check")).ServeHTTP(rec, req)

	span := checkutil.Span(t, sr.Ended(), "GET /items")
	if got := span.SpanContext().TraceID().String(); got != "4bf92f3577b34da6a3ce929d0e0e4736" {
		t.Errorf("trace id = %s, want the caller's 4bf92f3577b34da6a3ce929d0e0e4736", got)
	}
	if got := span.Parent().SpanID().String(); got != "00f067aa0ba902b7" {
		t.Errorf("parent span id = %s, want 00f067aa0ba902b7", got)
	}
	if !span.Parent().IsRemote() {
		t.Errorf("the parent should be marked remote")
	}
}
