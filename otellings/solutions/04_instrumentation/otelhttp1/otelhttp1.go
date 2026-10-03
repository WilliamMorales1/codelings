// otelhttp1 -- instrumenting a server with otelhttp
//
// You rarely start HTTP spans by hand. The contrib package
//
//   go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp
//
// wraps an http.Handler: for every request it extracts the incoming trace
// context (global propagator), starts a Server span, records the semconv
// HTTP attributes and status, and puts the span into r.Context().
// With Go's ServeMux patterns it also names the span after the matched
// route ("GET /books/{id}"), read from r.Pattern after the mux ran.
//
// By default otelhttp uses the global TracerProvider; tests and libraries
// pass one explicitly with otelhttp.WithTracerProvider.
//
// Task: wrap the mux with otelhttp.NewHandler, using tp.
//

package otelhttp1

import (
	"fmt"
	"net/http"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel/trace"
)

// NewServer returns the bookstore's HTTP handler.
func NewServer(tp trace.TracerProvider) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /books/{id}", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "book %s\n", r.PathValue("id"))
	})
	return otelhttp.NewHandler(mux, "bookstore", otelhttp.WithTracerProvider(tp))
}
