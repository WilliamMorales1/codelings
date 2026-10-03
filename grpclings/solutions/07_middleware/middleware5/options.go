// middleware5: retries and keepalive via the service config
//
// grpc-go retries failed calls by itself when the SERVICE CONFIG (a JSON
// document, from DNS or from grpc.WithDefaultServiceConfig) has a
// retryPolicy for the method. Only codes listed in retryableStatusCodes are
// retried: UNAVAILABLE ("try again") is the classic one. Never retry codes
// like INVALID_ARGUMENT or NOT_FOUND: the answer will not change. The
// "name" selects methods by FULL service name (package included); leaving out
// "method" means every method of that service.
//
// Idle connections die silently behind NATs and load balancers; keepalive
// pings notice. grpc.WithKeepaliveParams(keepalive.ClientParameters{...})
// sets them on the client, but a server rejects pings more frequent than its
// keepalive.EnforcementPolicy allows (default: one per 5 minutes) with
// GOAWAY "too_many_pings", so the two must be configured together.
//
// Task: the backend sometimes answers UNAVAILABLE while it restarts. Fix
// ServiceConfig so GetStock is retried (up to 4 attempts in total) on
// UNAVAILABLE, and only on UNAVAILABLE.
package middleware5

import (
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
)

// ServiceConfig is the default service config for StockService clients.
const ServiceConfig = `{
  "methodConfig": [{
    "name": [{"service": "stock.v1.StockService"}],
    "retryPolicy": {
      "maxAttempts": 4,
      "initialBackoff": "0.01s",
      "maxBackoff": "0.1s",
      "backoffMultiplier": 2,
      "retryableStatusCodes": ["UNAVAILABLE"]
    }
  }]
}`

// Options are the dial options for StockService clients.
func Options() []grpc.DialOption {
	return []grpc.DialOption{
		grpc.WithDefaultServiceConfig(ServiceConfig),
		grpc.WithKeepaliveParams(keepalive.ClientParameters{Time: time.Minute, Timeout: 10 * time.Second}),
	}
}
