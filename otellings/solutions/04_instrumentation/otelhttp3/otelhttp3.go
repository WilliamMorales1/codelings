// otelhttp3 -- keeping the context through a handler chain
//
// otelhttp puts the server span into r.Context(). Everything after it
// (middleware, handlers, the database layer) must pass *that* context down,
// or its spans become separate traces. Two common ways to lose it:
//
//   - middleware that builds a fresh context:
//       ctx := context.WithValue(context.Background(), ...)
//   - handlers that call context.Background() / context.TODO() "for now"
//
// Task: a request to GET /orders/{id} should produce one trace: the server
// span with "orders.load" as its child. Find both places that drop the
// request's context.
//

package otelhttp3

import (
	"context"
	"fmt"
	"net/http"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel/trace"
)

type userKey struct{}

type store struct{ tr trace.Tracer }

func (s store) load(ctx context.Context, id string) string {
	_, span := s.tr.Start(ctx, "orders.load")
	defer span.End()
	return "order " + id
}

// NewServer returns the orders service.
func NewServer(tp trace.TracerProvider) http.Handler {
	db := store{tr: tp.Tracer("otellings/otelhttp3")}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /orders/{id}", func(w http.ResponseWriter, r *http.Request) {
		user, _ := r.Context().Value(userKey{}).(string)
		fmt.Fprintf(w, "%s for %s\n", db.load(r.Context(), r.PathValue("id")), user)
	})
	return otelhttp.NewHandler(auth(mux), "orders", otelhttp.WithTracerProvider(tp))
}

// auth identifies the caller and stores the user in the request context.
func auth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := context.WithValue(r.Context(), userKey{}, r.Header.Get("X-User"))
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
