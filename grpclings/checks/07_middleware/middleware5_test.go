//go:build check

package middleware5

import (
	"context"
	"sync"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"grpclings/internal/check"
)

type flaky struct {
	UnimplementedStockServiceServer
	mu       sync.Mutex
	attempts map[string]int
}

func (f *flaky) GetStock(_ context.Context, r *GetStockRequest) (*GetStockResponse, error) {
	f.mu.Lock()
	f.attempts[r.GetSku()]++
	n := f.attempts[r.GetSku()]
	f.mu.Unlock()
	switch {
	case r.GetSku() == "missing":
		return nil, status.Error(codes.NotFound, "no such sku")
	case r.GetSku() == "broken":
		return nil, status.Error(codes.Internal, "bug")
	case n <= 2:
		return nil, status.Error(codes.Unavailable, "restarting")
	}
	return &GetStockResponse{Count: 42}, nil
}

func TestRetry(t *testing.T) {
	f := &flaky{attempts: map[string]int{}}
	lis := check.Listen(t, func(s *grpc.Server) { RegisterStockServiceServer(s, f) })
	c := NewStockServiceClient(check.Dial(t, lis, Options()...))

	res, err := c.GetStock(t.Context(), &GetStockRequest{Sku: "tea"})
	if err != nil {
		t.Errorf("GetStock failed after %d attempts: %v (UNAVAILABLE should be retried)", f.attempts["tea"], err)
	} else if res.GetCount() != 42 || f.attempts["tea"] != 3 {
		t.Errorf("got %v after %d attempts, want 42 after 3", res, f.attempts["tea"])
	}

	c.GetStock(t.Context(), &GetStockRequest{Sku: "missing"})
	c.GetStock(t.Context(), &GetStockRequest{Sku: "broken"})
	if f.attempts["missing"] != 1 || f.attempts["broken"] != 1 {
		t.Errorf("NOT_FOUND was tried %d times and INTERNAL %d times; only UNAVAILABLE may be retried",
			f.attempts["missing"], f.attempts["broken"])
	}
}
