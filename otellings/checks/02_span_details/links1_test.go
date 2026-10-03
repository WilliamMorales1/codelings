//go:build otellings_check

/* HINT
Build a []trace.Link{{SpanContext: m.Origin}, ...} and pass
trace.WithLinks(links...) to Start. Stop putting batch[0] in the context.
trace.WithNewRoot() also guarantees a fresh trace even if the caller's
context already carries a span.
*/

package links1

import (
	"testing"

	"otellings/checks/checkutil"

	"go.opentelemetry.io/otel/trace"
)

func TestLinks(t *testing.T) {
	sr, tp := checkutil.Tracing(t)
	tr := tp.Tracer("check")
	var batch []Message
	for _, body := range []string{"a", "b", "c"} {
		_, s := tr.Start(t.Context(), "enqueue "+body, trace.WithSpanKind(trace.SpanKindProducer))
		batch = append(batch, Message{Body: body, Origin: s.SpanContext()})
		s.End()
	}
	// The caller is itself inside a span; the batch still gets its own trace.
	ctx, outer := tr.Start(t.Context(), "poll")
	ProcessBatch(ctx, tr, batch)
	outer.End()

	span := checkutil.Span(t, sr.Ended(), "process batch")
	for _, m := range batch {
		if span.SpanContext().TraceID() == m.Origin.TraceID() {
			t.Errorf("process batch joined message %s's trace; it should be a new root", m.Body)
		}
	}
	if span.Parent().IsValid() {
		t.Errorf("process batch has a parent; it should be a root span with links")
	}
	links := span.Links()
	if len(links) != len(batch) {
		t.Fatalf("process batch has %d links, want %d", len(links), len(batch))
	}
	for i, m := range batch {
		if !links[i].SpanContext.Equal(m.Origin) {
			t.Errorf("link %d does not point at message %s", i, m.Body)
		}
	}
}
