// otelhttp2 -- instrumenting a client
//
// The client side of otelhttp is an http.RoundTripper: otelhttp.NewTransport
// wraps another transport, starts a Client span per request and injects the
// trace context into the outgoing headers.
//
// It can only do that if the request carries the caller's context. Helpers
// like client.Get(url) build a request with context.Background(), so the
// client span becomes the root of a new trace and the server's spans get
// disconnected from yours.
//
// Task: two things are missing.
//   1. NewClient must use an otelhttp transport (with tp, and wrapping
//      http.DefaultTransport).
//   2. FetchPrice must build its request with ctx.
//

package otelhttp2

import (
	"context"
	"io"
	"net/http"
	"strings"
	"time"

	"go.opentelemetry.io/otel/trace"
)

// NewClient returns the HTTP client the service uses for outgoing calls.
func NewClient(tp trace.TracerProvider) *http.Client {
	return &http.Client{Timeout: 5 * time.Second}
}

// FetchPrice asks the pricing service for sku's price.
func FetchPrice(ctx context.Context, c *http.Client, baseURL, sku string) (string, error) {
	resp, err := c.Get(baseURL + "/price/" + sku)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	b, err := io.ReadAll(resp.Body)
	return strings.TrimSpace(string(b)), err
}
