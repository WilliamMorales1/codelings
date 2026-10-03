//go:build check

package middleware2

import (
	"context"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
	"grpclings/internal/check"
)

func TestAuth(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterVaultServiceServer(s, Server{}) },
		grpc.ChainUnaryInterceptor(Auth(map[string]string{"s3cret": "ada"})))
	c := NewVaultServiceClient(conn)

	res, err := c.WhoAmI(WithToken(t.Context(), "s3cret"), &WhoAmIRequest{})
	if err != nil {
		t.Fatalf("WhoAmI with a valid token: %v", err)
	}
	if res.GetUser() != "ada" {
		t.Errorf("WhoAmI = %q, want ada", res.GetUser())
	}

	md, _ := metadata.FromOutgoingContext(WithToken(t.Context(), "x"))
	if got := md.Get("authorization"); len(got) != 1 || got[0] != "Bearer x" {
		t.Errorf(`WithToken(ctx, "x") should set authorization: Bearer x, metadata is %v`, md)
	}

	for name, ctx := range map[string]context.Context{
		"no token":    t.Context(),
		"wrong token": WithToken(t.Context(), "guess"),
	} {
		_, err := c.WhoAmI(ctx, &WhoAmIRequest{})
		if status.Code(err) != codes.Unauthenticated {
			t.Errorf("%s: error %v, want code Unauthenticated", name, err)
		}
	}
}
