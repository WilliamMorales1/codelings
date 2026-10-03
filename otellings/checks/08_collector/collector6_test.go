//go:build otellings_check

// REQUIRES: otelcol-contrib

/* HINT
The collector's OTLP/HTTP receiver serves traces at /v1/traces. Either

  otlptracehttp.WithEndpointURL(baseURL + "/v1/traces")

or build it from host:port with WithEndpoint(...) plus WithInsecure().
*/

package collector6

import (
	"strings"
	"testing"
	"time"

	"otellings/checks/checkutil"
)

func TestEndToEnd(t *testing.T) {
	col := checkutil.StartCollector(t, "config.yaml")
	if err := Send(t.Context(), col.Endpoint); err != nil {
		t.Fatalf("Send: %v", err)
	}
	if !col.WaitFor("nightly-report", 5*time.Second) {
		t.Fatalf("nightly-report never reached the debug exporter:\n%s", col.Tail(15))
	}
	out := col.Output()
	if !strings.Contains(out, "service.name: Str(reporter)") {
		t.Errorf("the resource (service.name=reporter) did not arrive")
	}
	if !strings.Contains(out, "query-sales") {
		t.Errorf("the child span query-sales is missing")
	}
}
