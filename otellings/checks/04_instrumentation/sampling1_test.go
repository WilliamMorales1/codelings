//go:build otellings_check

/* HINT
  sdktrace.WithSampler(sdktrace.TraceIDRatioBased(0.1))

(The same thing without code: OTEL_TRACES_SAMPLER=traceidratio and
OTEL_TRACES_SAMPLER_ARG=0.1, read by the SDK when no sampler is set.)
*/

package sampling1

import (
	"os"
	"testing"

	"go.opentelemetry.io/otel/sdk/trace/tracetest"
)

func TestTenPercent(t *testing.T) {
	t.Setenv("OTEL_TRACES_SAMPLER", "")
	os.Unsetenv("OTEL_TRACES_SAMPLER")
	sr := tracetest.NewSpanRecorder()
	tp := NewProvider(sr)
	tr := tp.Tracer("check")
	const n = 4000
	for range n {
		_, s := tr.Start(t.Context(), "req")
		s.End()
	}
	got := len(sr.Ended())
	// 10% of 4000 is 400; the standard deviation is about 19.
	if got < 320 || got > 480 {
		t.Errorf("%d of %d root spans were sampled, want about 10%% (400)", got, n)
	}
}
