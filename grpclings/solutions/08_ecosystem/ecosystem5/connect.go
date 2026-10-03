// ecosystem5: Connect, gRPC's plain-HTTP cousin
//
// connect-go (connectrpc.com/connect) serves the same protobuf services over
// ordinary net/http. One handler speaks three protocols: gRPC, gRPC-Web and
// Connect, whose unary calls are a plain POST with a JSON or binary body, so
// curl and browsers can call it without a proxy. Usually protoc-gen-connect-go
// generates handler constructors; underneath they are generic calls like:
//
//	connect.NewUnaryHandler(procedure, func(ctx context.Context, req *connect.Request[Req]) (*connect.Response[Res], error) {...})
//
// where procedure is the same path gRPC uses: "/package.Service/Method".
// Errors are connect.NewError(connect.CodeNotFound, err): Connect maps codes
// to HTTP statuses (404 here) and a JSON body {"code": "not_found", ...}.
//
// Task: fix NewHandler so that
//
//	curl -H 'Content-Type: application/json' -d '{"sku":"tea"}' \
//	     http://localhost:8080/shop.v1.ShopService/GetProduct
//
// returns the product, and an unknown SKU gets a proper not_found (HTTP 404)
// instead of an internal error.
package ecosystem5

import (
	"context"
	"fmt"
	"net/http"

	"connectrpc.com/connect"
)

var catalogue = map[string]*Product{
	"tea": {Sku: "tea", Name: "Green tea", PriceCents: 450},
}

func getProduct(_ context.Context, req *connect.Request[GetProductRequest]) (*connect.Response[GetProductResponse], error) {
	p, ok := catalogue[req.Msg.GetSku()]
	if !ok {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("no product %q", req.Msg.GetSku()))
	}
	return connect.NewResponse(&GetProductResponse{Product: p}), nil
}

// NewHandler returns the path to mount the handler on, and the handler.
func NewHandler() (string, http.Handler) {
	const procedure = "/shop.v1.ShopService/GetProduct"
	return procedure, connect.NewUnaryHandler(procedure, getProduct)
}
