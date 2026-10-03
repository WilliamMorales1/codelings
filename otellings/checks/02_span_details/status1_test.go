//go:build otellings_check

/* HINT
codes is go.opentelemetry.io/otel/codes:

  span.RecordError(err)
  span.SetStatus(codes.Error, err.Error())
*/

package status1

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/codes"
)

func TestErrorStatus(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	tr := tp.Tracer("check")
	if Charge(t.Context(), tr, -5) == nil {
		t.Fatal("Charge(-5) should fail")
	}
	if err := Charge(t.Context(), tr, 500); err != nil {
		t.Fatal(err)
	}
	failed, ok := sr.Ended()[0], sr.Ended()[1]

	if _, has := checkutil.Attr(failed.Attributes(), "error"); has {
		t.Errorf("drop the ad-hoc \"error\" attribute")
	}
	if st := failed.Status(); st.Code != codes.Error || st.Description != "invalid amount -5" {
		t.Errorf("failed span status = %v %q, want Error \"invalid amount -5\"", st.Code, st.Description)
	}
	var found bool
	for _, e := range failed.Events() {
		if e.Name == "exception" {
			found = true
			if v, _ := checkutil.Attr(e.Attributes, "exception.message"); v.AsString() != "invalid amount -5" {
				t.Errorf("exception.message = %q", v.AsString())
			}
		}
	}
	if !found {
		t.Errorf("failed span has no exception event; use span.RecordError")
	}
	if st := ok.Status(); st.Code != codes.Unset {
		t.Errorf("successful span status = %v, want Unset", st.Code)
	}
}
