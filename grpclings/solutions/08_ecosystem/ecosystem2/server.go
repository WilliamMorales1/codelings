// ecosystem2: server reflection
//
// A gRPC server does not describe itself unless you ask it to. With the
// reflection service registered, tools like grpcurl, grpcui, Postman and
// `buf curl` can list services and fetch their descriptors at runtime, so
// you can poke a server without the .proto files at hand. It exposes your
// schema, so many teams enable it only in development or behind auth.
//
// Task: make NewServer register the reflection service
// (google.golang.org/grpc/reflection) alongside the shop.
package ecosystem2

import (
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

// NewServer returns a gRPC server with the shop registered.
func NewServer() *grpc.Server {
	s := grpc.NewServer()
	RegisterShopServiceServer(s, Shop{})
	reflection.Register(s)
	return s
}
