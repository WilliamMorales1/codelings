// middleware2: authentication with metadata
//
// Metadata is gRPC's headers: string keys (always lowercase) with string
// values, next to the request. The two sides use different contexts:
//
//	client: ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer abc")
//	server: md, ok := metadata.FromIncomingContext(ctx); md.Get("authorization")
//
// An interceptor is the natural place to check credentials once for every
// RPC, and to hand the caller's identity to handlers through the context.
// Missing or wrong credentials are codes.Unauthenticated ("who are you?");
// codes.PermissionDenied means "I know you, and you may not".
//
// Task:
//  1. fix Auth, the server interceptor;
//  2. write WithToken, which the client uses to attach its token.
package middleware2

import (
	"context"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type userKey struct{}

// UserFrom returns the authenticated user that Auth stored in ctx.
func UserFrom(ctx context.Context) (string, bool) {
	u, ok := ctx.Value(userKey{}).(string)
	return u, ok
}

// Auth accepts requests carrying "authorization: Bearer <token>" for a token
// in tokens (token -> user name), and rejects all others with Unauthenticated.
func Auth(tokens map[string]string) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		md, _ := metadata.FromIncomingContext(ctx)
		for _, v := range md.Get("authorization") {
			token, ok := strings.CutPrefix(v, "Bearer ")
			if user, known := tokens[token]; ok && known {
				return handler(context.WithValue(ctx, userKey{}, user), req)
			}
		}
		return nil, status.Error(codes.Unauthenticated, "missing or unknown bearer token")
	}
}

// WithToken returns a context that makes RPCs carry token as a bearer token.
func WithToken(ctx context.Context, token string) context.Context {
	return metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+token)
}

// Server answers with the caller's name.
type Server struct {
	UnimplementedVaultServiceServer
}

func (Server) WhoAmI(ctx context.Context, _ *WhoAmIRequest) (*WhoAmIResponse, error) {
	user, _ := UserFrom(ctx)
	return &WhoAmIResponse{User: user}, nil
}
