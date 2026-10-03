//go:build otellings_check

/* HINT
Pick the threshold from kind: 500 for trace.SpanKindServer, 400 otherwise.
*/

package status2

import (
	"fmt"
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

func TestStatusBySide(t *testing.T) {
	cases := []struct {
		kind trace.SpanKind
		code int
		want codes.Code
	}{
		{trace.SpanKindServer, 200, codes.Unset},
		{trace.SpanKindServer, 404, codes.Unset},
		{trace.SpanKindServer, 503, codes.Error},
		{trace.SpanKindClient, 200, codes.Unset},
		{trace.SpanKindClient, 404, codes.Error},
		{trace.SpanKindClient, 500, codes.Error},
	}
	for _, c := range cases {
		sr, tp := checkutil.Tracing(t)
		_, span := tp.Tracer("check").Start(t.Context(), "req", trace.WithSpanKind(c.kind))
		SetHTTPStatus(span, c.kind, c.code)
		span.End()
		st := sr.Ended()[0].Status()
		if st.Code != c.want {
			t.Errorf("%s span, HTTP %d: status %v, want %v", c.kind, c.code, st.Code, c.want)
		}
		if c.want == codes.Error && st.Description != fmt.Sprintf("HTTP %d", c.code) {
			t.Errorf("%s span, HTTP %d: description %q", c.kind, c.code, st.Description)
		}
	}
}
