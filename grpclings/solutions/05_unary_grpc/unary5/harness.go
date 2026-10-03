// unary5: testing over an in-memory connection
//
// Tests that listen on a fixed TCP port collide as soon as two run at once
// (go test runs packages, and t.Parallel tests, concurrently), and they trip
// firewalls in CI. google.golang.org/grpc/test/bufconn gives you a
// net.Listener backed by memory:
//
//	lis := bufconn.Listen(1 << 20)                 // buffer size
//	go srv.Serve(lis)
//	grpc.NewClient("passthrough:///bufnet",
//	    grpc.WithContextDialer(func(ctx context.Context, _ string) (net.Conn, error) {
//	        return lis.DialContext(ctx)
//	    }),
//	    grpc.WithTransportCredentials(insecure.NewCredentials()))
//
// "passthrough:///" stops gRPC from trying to resolve the name via DNS.
// Everything else (interceptors, codecs, status codes, metadata) is real.
//
// Task: rewrite Start to use bufconn instead of TCP port 50051, so any
// number of harnesses can run at the same time.
package unary5

import (
	"context"
	"net"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/test/bufconn"
)

// Start runs a gRPC server with whatever register adds to it, and returns a
// client connection to it plus a function that shuts both down.
func Start(register func(*grpc.Server)) (*grpc.ClientConn, func(), error) {
	lis := bufconn.Listen(1 << 20)
	srv := grpc.NewServer()
	register(srv)
	go srv.Serve(lis)

	conn, err := grpc.NewClient("passthrough:///bufnet",
		grpc.WithContextDialer(func(ctx context.Context, _ string) (net.Conn, error) {
			return lis.DialContext(ctx)
		}),
		grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		srv.Stop()
		return nil, nil, err
	}
	return conn, func() { conn.Close(); srv.Stop() }, nil
}
