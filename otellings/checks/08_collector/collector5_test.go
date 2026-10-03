//go:build otellings_check

// REQUIRES: otelcol-contrib

/* HINT
  exporters:
    otlp_http:
      endpoint: ${env:UPSTREAM_ENDPOINT}

  ...
      exporters: [debug, otlp_http]

The otlp_http exporter appends /v1/traces to the endpoint itself.
*/

package collector5

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/trace"
)

func TestFanOut(t *testing.T) {
	paths := make(chan string, 10)
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		paths <- r.URL.Path
		w.Header().Set("Content-Type", "application/x-protobuf")
	}))
	defer upstream.Close()

	col := checkutil.StartCollector(t, "config.yaml", "UPSTREAM_ENDPOINT="+upstream.URL)
	col.SendSpans(t, "collector5-check", func(ctx context.Context, tr trace.Tracer) {
		_, s := tr.Start(ctx, "fan-out")
		s.End()
	})
	select {
	case p := <-paths:
		if p != "/v1/traces" {
			t.Errorf("upstream got a request for %s, want /v1/traces", p)
		}
	case <-time.After(5 * time.Second):
		t.Errorf("nothing reached UPSTREAM_ENDPOINT (%s)", upstream.URL)
	}
	if !col.WaitFor("fan-out", 3*time.Second) && !col.WaitFor(`"spans": 1`, time.Second) {
		t.Errorf("the debug exporter should still see the span:\n%s", col.Tail(15))
	}
}
