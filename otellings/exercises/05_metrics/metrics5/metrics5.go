// metrics5 -- views: reshaping metrics you do not own
//
// library.go is a dependency that records its own metrics, and it made two
// poor choices: its duration histogram uses the default (millisecond-sized)
// buckets although it records seconds, and its cache counter carries the
// cache key as an attribute, one time series per key, forever.
//
// A *view*, registered on the MeterProvider, changes how the SDK aggregates
// matching instruments without touching their code:
//
//   sdkmetric.NewView(
//       sdkmetric.Instrument{Name: "...", Scope: ...},   // what to match
//       sdkmetric.Stream{Aggregation: ..., AttributeFilter: ...}, // what to change
//   )
//
// Task: add two views in NewProvider:
//   1. rpc.client.call.duration: explicit buckets 0.01, 0.1, 1, 10
//   2. rpc.client.cache.lookups: keep only the cache.hit attribute
//

package metrics5

import (
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
)

// NewProvider builds the application's MeterProvider.
func NewProvider(r sdkmetric.Reader) *sdkmetric.MeterProvider {
	return sdkmetric.NewMeterProvider(
		sdkmetric.WithReader(r),
	)
}
