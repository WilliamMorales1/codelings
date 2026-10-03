// status2 -- which HTTP responses are errors?
//
// The HTTP semantic conventions answer this differently per side:
//
//   client span (you called someone):  4xx and 5xx are errors
//   server span (someone called you):  only 5xx is an error; a 4xx means the
//                                      *caller* got it wrong, and your
//                                      service is working as designed
//
// Mark every 404 on a server red and your error-rate alerts fire whenever a
// crawler guesses URLs.
//
// Task: SetHTTPStatus treats both sides the same. Make it follow the rules
// above; leave the status Unset for anything that is not an error. Use the
// status code number ("HTTP 404") as description.
//

package status2

import (
	"fmt"

	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

// SetHTTPStatus sets span's status from the response code. kind is
// trace.SpanKindServer or trace.SpanKindClient.
func SetHTTPStatus(span trace.Span, kind trace.SpanKind, code int) {
	limit := 400
	if kind == trace.SpanKindServer {
		limit = 500
	}
	if code >= limit {
		span.SetStatus(codes.Error, fmt.Sprintf("HTTP %d", code))
	}
}
