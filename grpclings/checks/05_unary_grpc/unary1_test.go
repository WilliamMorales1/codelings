//go:build check

package unary1

import (
	"testing"

	"google.golang.org/grpc"
	"grpclings/internal/check"
)

func TestSayHello(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterGreeterServiceServer(s, Greeter{}) })
	res, err := NewGreeterServiceClient(conn).SayHello(t.Context(), &SayHelloRequest{Name: "gRPC"})
	if err != nil {
		t.Fatal(err)
	}
	if res.GetGreeting() != "Hello, gRPC!" {
		t.Errorf("greeting = %q", res.GetGreeting())
	}
	if GreeterService_SayHello_FullMethodName != "/greet.v1.GreeterService/SayHello" {
		t.Errorf("the RPC's full name is %s, want /greet.v1.GreeterService/SayHello", GreeterService_SayHello_FullMethodName)
	}
}
