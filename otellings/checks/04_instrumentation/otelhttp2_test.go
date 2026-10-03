//go:build otellings_check

/* HINT
  Transport: otelhttp.NewTransport(http.DefaultTransport, otelhttp.WithTracerProvider(tp)),

and

  req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
  resp, err := c.Do(req)
*/

package otelhttp2

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/propagation"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

func TestClientSpanAndPropagation(t *testing.T) {
	otel.SetTextMapPropagator(propagation.TraceContext{})
	var gotHeader string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotHeader = r.Header.Get("traceparent")
		fmt.Fprintln(w, "4.20")
	}))
	defer srv.Close()

	sr, tp := checkutil.Tracing(t)
	ctx, parent := tp.Tracer("check").Start(t.Context(), "checkout")
	price, err := FetchPrice(ctx, NewClient(tp), srv.URL, "tea")
	parent.End()
	if err != nil || price != "4.20" {
		t.Fatalf("FetchPrice = %q, %v", price, err)
	}

	var client sdktrace.ReadOnlySpan
	for _, s := range sr.Ended() {
		if s.SpanKind() == trace.SpanKindClient {
			client = s
		}
	}
	if client == nil {
		t.Fatalf("no client span; spans: %v", checkutil.Names(sr.Ended()))
	}
	if client.Parent().SpanID() != parent.SpanContext().SpanID() {
		t.Errorf("the client span is not a child of checkout: pass ctx into the request")
	}
	want := fmt.Sprintf("00-%s-%s-01", client.SpanContext().TraceID(), client.SpanContext().SpanID())
	if gotHeader != want {
		t.Errorf("server saw traceparent %q, want %q", gotHeader, want)
	}
}
