//go:build check

package middleware4

import (
	"context"
	"testing"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"grpclings/internal/check"
)

// backend waits until its context ends, and reports how long it had.
type backend struct {
	UnimplementedPriceServiceServer
	budget chan time.Duration
}

func (b backend) GetPrice(ctx context.Context, _ *GetPriceRequest) (*GetPriceResponse, error) {
	dl, ok := ctx.Deadline()
	if !ok {
		b.budget <- -1
	} else {
		b.budget <- time.Until(dl)
	}
	select {
	case <-ctx.Done():
		return nil, status.FromContextError(ctx.Err()).Err()
	case <-time.After(3 * time.Second):
		return &GetPriceResponse{Cents: 100}, nil
	}
}

func TestPropagation(t *testing.T) {
	b := backend{budget: make(chan time.Duration, 4)}
	backConn := check.Serve(t, func(s *grpc.Server) { RegisterPriceServiceServer(s, b) })
	frontConn := check.Serve(t, func(s *grpc.Server) {
		RegisterPriceServiceServer(s, &Frontend{Backend: NewPriceServiceClient(backConn)})
	})

	ctx, cancel := context.WithTimeout(t.Context(), 200*time.Millisecond)
	defer cancel()
	_, err := NewPriceServiceClient(frontConn).GetPrice(ctx, &GetPriceRequest{Sku: "tea"})
	if status.Code(err) != codes.DeadlineExceeded {
		t.Errorf("frontend call: %v, want DeadlineExceeded", err)
	}
	budget := <-b.budget
	if budget < 0 || budget > 250*time.Millisecond {
		t.Errorf("the backend was given %s; it should inherit the caller's ~200ms", budget.Round(time.Millisecond))
	}
}

func TestDefaultTimeout(t *testing.T) {
	b := backend{budget: make(chan time.Duration, 4)}
	lis := check.Listen(t, func(s *grpc.Server) { RegisterPriceServiceServer(s, b) })
	c := NewPriceServiceClient(check.Dial(t, lis, grpc.WithChainUnaryInterceptor(DefaultTimeout(150*time.Millisecond))))

	start := time.Now()
	_, err := c.GetPrice(t.Context(), &GetPriceRequest{})
	if status.Code(err) != codes.DeadlineExceeded || time.Since(start) > time.Second {
		t.Errorf("a call without a deadline: %v after %s, want DeadlineExceeded after ~150ms", err, time.Since(start).Round(time.Millisecond))
	}
	<-b.budget

	ctx, cancel := context.WithTimeout(t.Context(), 400*time.Millisecond)
	defer cancel()
	_, _ = c.GetPrice(ctx, &GetPriceRequest{})
	if got := <-b.budget; got < 250*time.Millisecond {
		t.Errorf("a call with its own 400ms deadline reached the server with only %s: keep existing deadlines", got.Round(time.Millisecond))
	}
}
