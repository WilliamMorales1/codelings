//go:build check

package middleware3

import (
	"errors"
	"io"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
	"grpclings/internal/check"
)

func TestStreamAuth(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterFeedServiceServer(s, Server{}) },
		grpc.ChainStreamInterceptor(StreamAuth(map[string]string{"tok": "grace"})))
	c := NewFeedServiceClient(conn)

	ctx := metadata.AppendToOutgoingContext(t.Context(), "authorization", "Bearer tok")
	stream, err := c.Subscribe(ctx, &SubscribeRequest{Count: 2})
	if err != nil {
		t.Fatal(err)
	}
	var got []string
	for {
		ev, err := stream.Recv()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			t.Fatalf("Recv: %v", err)
		}
		got = append(got, ev.GetText())
	}
	if len(got) != 2 || got[1] != "event 2 for grace" {
		t.Errorf("events = %q", got)
	}

	stream, _ = c.Subscribe(t.Context(), &SubscribeRequest{Count: 1})
	if _, err := stream.Recv(); status.Code(err) != codes.Unauthenticated {
		t.Errorf("without a token: %v, want Unauthenticated", err)
	}
}
