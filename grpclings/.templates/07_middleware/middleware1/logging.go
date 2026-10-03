// middleware1: a unary server interceptor
//
// An interceptor is gRPC's middleware: a function wrapped around every RPC.
// For unary RPCs on the server it has this shape:
//
//	func(ctx context.Context, req any, info *grpc.UnaryServerInfo,
//	     handler grpc.UnaryHandler) (resp any, err error)
//
// info.FullMethod is "/package.Service/Method"; calling handler(ctx, req)
// runs the actual RPC (or the next interceptor). Install with
// grpc.NewServer(grpc.ChainUnaryInterceptor(a, b, ...)).
//
// Task: write Logging so that after every RPC it logs ONE record through
// logger, at Info level, with message "rpc" and these attributes:
//
//	method    info.FullMethod
//	code      the status code as a string, e.g. "OK", "NotFound"
//	          (status.Code(err).String())
//	duration  how long the handler took (a time.Duration)
//
// and returns exactly what the handler returned.
package middleware1

import (
	"context"
	"log/slog"

	"google.golang.org/grpc"
)

// Logging returns an interceptor that logs every unary RPC.
func Logging(logger *slog.Logger) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		// TODO
		return nil, nil
	}
}
