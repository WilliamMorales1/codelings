package unary1

import "context"

// Greeter implements GreeterServiceServer.
type Greeter struct {
	// Embedding (by value) keeps old servers compiling when RPCs are added to
	// the service: new methods return codes.Unimplemented until written.
	UnimplementedGreeterServiceServer
}

func (Greeter) SayHello(_ context.Context, req *SayHelloRequest) (*SayHelloResponse, error) {
	return &SayHelloResponse{Greeting: "Hello, " + req.GetName() + "!"}, nil
}
