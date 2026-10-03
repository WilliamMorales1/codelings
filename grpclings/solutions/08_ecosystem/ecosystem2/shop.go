package ecosystem2

import (
	"context"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Shop serves a tiny fixed catalogue. It is already done.
type Shop struct{ UnimplementedShopServiceServer }

var catalogue = map[string]*Product{
	"tea": {Sku: "tea", Name: "Green tea", PriceCents: 450},
	"mug": {Sku: "mug", Name: "Blue mug", PriceCents: 1200},
}

func (Shop) GetProduct(_ context.Context, req *GetProductRequest) (*GetProductResponse, error) {
	p, ok := catalogue[req.GetSku()]
	if !ok {
		return nil, status.Errorf(codes.NotFound, "no product %q", req.GetSku())
	}
	return &GetProductResponse{Product: p}, nil
}
