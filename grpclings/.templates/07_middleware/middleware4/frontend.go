// middleware4: propagating deadlines
//
// A request enters the frontend with a deadline ("answer within 200ms"). The
// frontend calls a backend. If it makes that call with a fresh
// context.Background(), the backend never learns the caller gave up: it
// keeps working (and holding resources) long after anyone cares. Pass the
// INCOMING ctx along instead; gRPC then sends the remaining time with the
// outgoing call, and cancellation follows the whole chain.
//
// The opposite problem sits on the client: a call with no deadline at all.
// A client interceptor can add a default:
//
//	func(ctx context.Context, method string, req, reply any, cc *grpc.ClientConn,
//	     invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error
//
// where invoker(ctx, method, req, reply, cc, opts...) performs the call.
// Install with grpc.WithChainUnaryInterceptor(...) on grpc.NewClient.
//
// Task:
//  1. Frontend.GetPrice: propagate the caller's deadline and cancellation.
//  2. DefaultTimeout: give calls without a deadline one of d; leave calls
//     that already have a deadline alone.
package middleware4

import (
	"context"
	"time"

	"google.golang.org/grpc"
)

// Frontend forwards price lookups to a backend PriceService.
type Frontend struct {
	UnimplementedPriceServiceServer
	Backend PriceServiceClient
}

func (f *Frontend) GetPrice(_ context.Context, req *GetPriceRequest) (*GetPriceResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return f.Backend.GetPrice(ctx, req)
}

// DefaultTimeout is a client interceptor that bounds calls made without a deadline.
func DefaultTimeout(d time.Duration) grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply any, cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {
		// TODO
		return invoker(ctx, method, req, reply, cc, opts...)
	}
}
