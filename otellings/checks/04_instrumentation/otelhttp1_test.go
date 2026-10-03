//go:build otellings_check

/* HINT
  return otelhttp.NewHandler(mux, "bookstore", otelhttp.WithTracerProvider(tp))

The second argument is the "operation" name, used when there is no route.
*/

package otelhttp1

import (
	"net/http/httptest"
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/trace"
)

func TestServerSpan(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	rec := httptest.NewRecorder()
	NewServer(tp).ServeHTTP(rec, httptest.NewRequest("GET", "/books/42", nil))
	if rec.Code != 200 || rec.Body.String() != "book 42\n" {
		t.Fatalf("handler answered %d %q", rec.Code, rec.Body.String())
	}
	spans := sr.Ended()
	if len(spans) != 1 {
		t.Fatalf("got %d spans, want one server span", len(spans))
	}
	s := spans[0]
	if s.Name() != "GET /books/{id}" {
		t.Errorf("span name = %q, want \"GET /books/{id}\"", s.Name())
	}
	if s.SpanKind() != trace.SpanKindServer {
		t.Errorf("span kind = %s, want server", s.SpanKind())
	}
	for key, want := range map[string]string{
		"http.request.method":       "GET",
		"url.path":                  "/books/42",
		"http.response.status_code": "200",
	} {
		if v, _ := checkutil.Attr(s.Attributes(), key); v.Emit() != want {
			t.Errorf("%s = %q, want %q", key, v.Emit(), want)
		}
	}
}
