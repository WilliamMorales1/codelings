// unary3: a client with a deadline
//
// grpc.NewClient(target, opts...) creates a *grpc.ClientConn. It does not
// connect yet (that happens lazily, on the first RPC), and it insists that
// you choose transport security: TLS credentials, or explicitly
// insecure.NewCredentials() for plaintext on a trusted network.
//
// Every RPC takes a context. Without a deadline, a call to a stuck server
// waits forever and so does your caller. gRPC sends the deadline to the
// server too (as the grpc-timeout header), so the server can give up early.
//
// Task:
//  1. make Dial produce a working plaintext connection to addr;
//  2. make Forecast give up after 300ms, however long the server takes.
package unary3

import (
	"context"

	"google.golang.org/grpc"
)

// Dial connects to a WeatherService at addr ("host:port"), without TLS.
func Dial(addr string) (*grpc.ClientConn, error) {
	return grpc.NewClient(addr)
}

// Forecast asks for the city's forecast, waiting at most 300ms.
func Forecast(ctx context.Context, c WeatherServiceClient, city string) (*GetForecastResponse, error) {
	return c.GetForecast(ctx, &GetForecastRequest{City: city})
}
