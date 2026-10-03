// ecosystem4: rich error details
//
// A status code plus a message is often too little: a form wants to know
// WHICH fields are wrong. gRPC statuses can carry typed detail messages
// (google.rpc.BadRequest, RetryInfo, ErrorInfo, ... from
// google.golang.org/genproto/googleapis/rpc/errdetails):
//
//	server: st, err := status.New(codes.InvalidArgument, "msg").WithDetails(&errdetails.BadRequest{...})
//	        return nil, st.Err()
//	client: for _, d := range status.Convert(err).Details() { switch d := d.(type) { ... } }
//
// They travel in the grpc-status-details-bin trailer; every language can read them.
//
// Task:
//  1. Validate: reject a product with an empty sku, or a negative price,
//     with InvalidArgument carrying ONE BadRequest that lists a
//     FieldViolation per bad field (Field "sku" / "price_cents").
//  2. Violations: turn such an error back into field -> description.
package ecosystem4

import (
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Validate checks p and returns a status error describing every problem, or nil.
func Validate(p *Product) error {
	var violations []*errdetails.BadRequest_FieldViolation
	if p.GetSku() == "" {
		violations = append(violations, &errdetails.BadRequest_FieldViolation{Field: "sku", Description: "must not be empty"})
	}
	if p.GetPriceCents() < 0 {
		violations = append(violations, &errdetails.BadRequest_FieldViolation{Field: "price_cents", Description: "must not be negative"})
	}
	if len(violations) == 0 {
		return nil
	}
	st, err := status.New(codes.InvalidArgument, "invalid product").
		WithDetails(&errdetails.BadRequest{FieldViolations: violations})
	if err != nil {
		return status.Error(codes.Internal, err.Error())
	}
	return st.Err()
}

// Violations extracts field -> description from an error made by Validate.
// It returns nil when err carries no BadRequest.
func Violations(err error) map[string]string {
	var out map[string]string
	for _, d := range status.Convert(err).Details() {
		br, ok := d.(*errdetails.BadRequest)
		if !ok {
			continue
		}
		if out == nil {
			out = map[string]string{}
		}
		for _, v := range br.GetFieldViolations() {
			out[v.GetField()] = v.GetDescription()
		}
	}
	return out
}
