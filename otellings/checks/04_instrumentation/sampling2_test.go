//go:build otellings_check

/* HINT
Wrap the ratio sampler:

  sdktrace.ParentBased(sdktrace.TraceIDRatioBased(0.1))

(Environment equivalent: OTEL_TRACES_SAMPLER=parentbased_traceidratio.)
*/

package sampling2

import (
	"crypto/rand"
	"testing"

	"go.opentelemetry.io/otel/sdk/trace/tracetest"
	"go.opentelemetry.io/otel/trace"
)

func remoteParent(sampled bool) trace.SpanContext {
	var tid trace.TraceID
	var sid trace.SpanID
	rand.Read(tid[:])
	rand.Read(sid[:])
	var flags trace.TraceFlags
	if sampled {
		flags = trace.FlagsSampled
	}
	return trace.NewSpanContext(trace.SpanContextConfig{TraceID: tid, SpanID: sid, TraceFlags: flags, Remote: true})
}

func TestFollowsParent(t *testing.T) {
	sr := tracetest.NewSpanRecorder()
	tr := NewProvider(sr).Tracer("check")
	count := func(sampled bool) int {
		before := len(sr.Ended())
		for range 1000 {
			ctx := trace.ContextWithRemoteSpanContext(t.Context(), remoteParent(sampled))
			_, s := tr.Start(ctx, "server")
			s.End()
		}
		return len(sr.Ended()) - before
	}
	if got := count(true); got != 1000 {
		t.Errorf("only %d of 1000 requests with a sampled parent were recorded, want all", got)
	}
	if got := count(false); got != 0 {
		t.Errorf("%d of 1000 requests with an unsampled parent were recorded, want none", got)
	}
	before := len(sr.Ended())
	for range 4000 {
		_, s := tr.Start(t.Context(), "root")
		s.End()
	}
	if got := len(sr.Ended()) - before; got < 320 || got > 480 {
		t.Errorf("%d of 4000 root spans sampled, want about 400", got)
	}
}
