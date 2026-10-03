// middleware3: stream interceptors and wrapped streams
//
// Streaming RPCs have their own interceptor type:
//
//	func(srv any, ss grpc.ServerStream, info *grpc.StreamServerInfo,
//	     handler grpc.StreamHandler) error
//
// There is no ctx argument to replace: the handler gets its context from
// ss.Context(). To hand the handler a new context (say, with the user in it)
// you wrap the stream in a type that embeds grpc.ServerStream and overrides
// Context(). The same trick lets you override RecvMsg/SendMsg, e.g. to count
// or log messages.
// Install with grpc.NewServer(grpc.ChainStreamInterceptor(...)).
//
// Task: StreamAuth already checks the token; make the handler actually see
// the user it found.
package middleware3

import (
	"context"
	"fmt"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type userKey struct{}

// UserFrom returns the authenticated user stored in ctx.
func UserFrom(ctx context.Context) (string, bool) {
	u, ok := ctx.Value(userKey{}).(string)
	return u, ok
}

// authedStream is ss with a replaced context.
type authedStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (s *authedStream) Context() context.Context { return s.ctx }

// StreamAuth accepts streams carrying "authorization: Bearer <token>" for a
// known token and makes the user available to the handler via UserFrom.
func StreamAuth(tokens map[string]string) grpc.StreamServerInterceptor {
	return func(srv any, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		md, _ := metadata.FromIncomingContext(ss.Context())
		for _, v := range md.Get("authorization") {
			token, ok := strings.CutPrefix(v, "Bearer ")
			if user, known := tokens[token]; ok && known {
				ctx := context.WithValue(ss.Context(), userKey{}, user)
				return handler(srv, &authedStream{ServerStream: ss, ctx: ctx})
			}
		}
		return status.Error(codes.Unauthenticated, "missing or unknown bearer token")
	}
}

// Server streams personalised events.
type Server struct{ UnimplementedFeedServiceServer }

func (Server) Subscribe(req *SubscribeRequest, stream grpc.ServerStreamingServer[Event]) error {
	user, ok := UserFrom(stream.Context())
	if !ok {
		return status.Error(codes.Internal, "handler reached without a user in its context")
	}
	for i := range req.GetCount() {
		if err := stream.Send(&Event{Text: fmt.Sprintf("event %d for %s", i+1, user)}); err != nil {
			return err
		}
	}
	return nil
}
