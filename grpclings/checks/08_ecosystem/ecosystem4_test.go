//go:build check

package ecosystem4

import (
	"context"
	"maps"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"grpclings/internal/check"
)

type shop struct{ UnimplementedShopServiceServer }

func (shop) GetProduct(_ context.Context, r *GetProductRequest) (*GetProductResponse, error) {
	p := &Product{Sku: r.GetSku(), PriceCents: -5}
	if err := Validate(p); err != nil {
		return nil, err
	}
	return &GetProductResponse{Product: p}, nil
}

func TestDetails(t *testing.T) {
	if err := Validate(&Product{Sku: "tea", PriceCents: 450}); err != nil {
		t.Errorf("a valid product: %v", err)
	}
	c := NewShopServiceClient(check.Serve(t, func(s *grpc.Server) { RegisterShopServiceServer(s, shop{}) }))
	// Through a real RPC: details must survive the trip in the trailers.
	_, err := c.GetProduct(t.Context(), &GetProductRequest{Sku: ""})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("error %v, want InvalidArgument", err)
	}
	if n := len(status.Convert(err).Details()); n != 1 {
		t.Errorf("the status carries %d details, want 1 BadRequest", n)
	}
	want := map[string]string{"sku": "must not be empty", "price_cents": "must not be negative"}
	if got := Violations(err); !maps.Equal(got, want) {
		t.Errorf("Violations = %v, want %v", got, want)
	}
	_, err = c.GetProduct(t.Context(), &GetProductRequest{Sku: "tea"})
	if got := Violations(err); !maps.Equal(got, map[string]string{"price_cents": "must not be negative"}) {
		t.Errorf("Violations = %v", got)
	}
	if got := Violations(status.Error(codes.NotFound, "x")); got != nil {
		t.Errorf("Violations of a plain status = %v, want nil", got)
	}
}
