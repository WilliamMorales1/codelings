package metrics5

import (
	"context"
	"time"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

// This file stands in for a third-party library. You cannot change it.

// Client is an RPC client that instruments itself.
type Client struct {
	duration metric.Float64Histogram
	lookups  metric.Int64Counter
}

func NewClient(mp metric.MeterProvider) *Client {
	m := mp.Meter("example.com/rpc")
	d, _ := m.Float64Histogram("rpc.client.call.duration", metric.WithUnit("s"))
	l, _ := m.Int64Counter("rpc.client.cache.lookups")
	return &Client{duration: d, lookups: l}
}

func (c *Client) Call(ctx context.Context, method string, took time.Duration, cacheKey string, hit bool) {
	c.lookups.Add(ctx, 1, metric.WithAttributes(
		attribute.String("cache.key", cacheKey),
		attribute.Bool("cache.hit", hit),
	))
	c.duration.Record(ctx, took.Seconds(), metric.WithAttributes(attribute.String("rpc.method", method)))
}
