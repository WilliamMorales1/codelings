// attributes2 -- semantic conventions
//
// If every team invents its own attribute names, no dashboard works across
// services. The OpenTelemetry *semantic conventions* fix the names for
// common things: HTTP, databases, messaging, cloud, and so on. The Go module
// ships them as constants and helpers, one package per spec version:
//
//   import semconv "go.opentelemetry.io/otel/semconv/v1.43.0"
//
// The HTTP conventions were renamed when they went stable. Old code (and old
// blog posts) still use http.method, http.status_code and net.peer.name.
//
// Task: Annotate uses the pre-stable names. Switch to the current ones via
// the semconv package:
//   http.request.method, url.path, http.response.status_code, server.address
//

package attributes2

import (
	"net/http"

	semconv "go.opentelemetry.io/otel/semconv/v1.43.0"
	"go.opentelemetry.io/otel/trace"
)

// Annotate describes an HTTP exchange on span.
func Annotate(span trace.Span, r *http.Request, status int) {
	span.SetAttributes(
		semconv.HTTPRequestMethodKey.String(r.Method),
		semconv.URLPath(r.URL.Path),
		semconv.HTTPResponseStatusCode(status),
		semconv.ServerAddress(r.URL.Hostname()),
	)
}
