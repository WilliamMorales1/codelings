//go:build otellings_check

/* HINT
  semconv.HTTPRequestMethodKey.String(r.Method)
  semconv.URLPath(r.URL.Path)
  semconv.HTTPResponseStatusCode(status)
  semconv.ServerAddress(r.URL.Hostname())

The method is an enum in the spec, so it has a Key plus constants such as
semconv.HTTPRequestMethodGet rather than a helper function.
*/

package attributes2

import (
	"net/http/httptest"
	"testing"

	"otellings/checks/checkutil"
)

func TestSemconvNames(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	_, span := tp.Tracer("check").Start(t.Context(), "GET /books/{id}")
	Annotate(span, httptest.NewRequest("GET", "http://shop.example:8080/books/7?x=1", nil), 404)
	span.End()
	attrs := sr.Ended()[0].Attributes()

	for _, old := range []string{"http.method", "http.target", "http.status_code", "net.peer.name"} {
		if _, ok := checkutil.Attr(attrs, old); ok {
			t.Errorf("%s is a pre-stable name; remove it", old)
		}
	}
	want := map[string]string{
		"http.request.method":       "GET",
		"url.path":                  "/books/7",
		"http.response.status_code": "404",
		"server.address":            "shop.example",
	}
	for key, val := range want {
		v, ok := checkutil.Attr(attrs, key)
		if !ok {
			t.Errorf("missing %s", key)
		} else if v.Emit() != val {
			t.Errorf("%s = %q, want %q", key, v.Emit(), val)
		}
	}
	if v, _ := checkutil.Attr(attrs, "http.response.status_code"); v.Type().String() != "INT64" {
		t.Errorf("http.response.status_code should be an int, got %s", v.Type())
	}
}
