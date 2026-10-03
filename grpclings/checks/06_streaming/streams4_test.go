//go:build check

package streams4

import (
	"context"
	"testing"
	"time"

	"google.golang.org/grpc"
	"grpclings/internal/check"
)

func TestCancel(t *testing.T) {
	clock := &Clock{Interval: 20 * time.Millisecond}
	returned := make(chan time.Time, 1)
	// A stream interceptor sees the handler return, which the client cannot.
	watch := grpc.StreamInterceptor(func(srv any, ss grpc.ServerStream, info *grpc.StreamServerInfo, h grpc.StreamHandler) error {
		err := h(srv, ss)
		returned <- time.Now()
		return err
	})
	conn := check.Serve(t, func(s *grpc.Server) { RegisterClockServiceServer(s, clock) }, watch)

	ctx, cancel := context.WithCancel(t.Context())
	stream, err := NewClockServiceClient(conn).Watch(ctx, &WatchRequest{})
	if err != nil {
		t.Fatal(err)
	}
	for want := int64(1); want <= 3; want++ {
		tick, err := stream.Recv()
		if err != nil || tick.GetN() != want {
			t.Fatalf("tick %d: got %v, %v", want, tick, err)
		}
	}
	// Make the next tick far away: only cancellation can end the handler quickly now.
	clock.Interval = 10 * time.Second
	time.Sleep(50 * time.Millisecond)
	cancelled := time.Now()
	cancel()

	select {
	case at := <-returned:
		t.Logf("handler returned %s after the client cancelled", at.Sub(cancelled).Round(time.Millisecond))
	case <-time.After(time.Second):
		t.Fatal("the Watch handler was still running 1s after the client cancelled")
	}
}
