// unary4: status codes
//
// A gRPC error is a status: a code (codes.NotFound, codes.InvalidArgument,
// codes.Unavailable, ...) plus a message. Clients, proxies and retry logic
// act on the CODE; the message is for humans and may change any time.
//
//	server: return nil, status.Errorf(codes.NotFound, "account %q", id)
//	client: status.Code(err) == codes.NotFound
//
// A plain Go error (errors.New, fmt.Errorf) reaches the client as
// codes.Unknown, which tells it nothing.
//
// Task:
//  1. Server.GetBalance: an empty account_id is InvalidArgument, an unknown
//     one is NotFound.
//  2. Balance (the client helper) must return ErrNoAccount for NotFound,
//     whatever the server's message says, and the error unchanged otherwise.
package unary4

import (
	"context"
	"errors"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Server serves balances from a fixed map.
type Server struct {
	UnimplementedBankServiceServer
	Balances map[string]int64
}

func (s *Server) GetBalance(_ context.Context, req *GetBalanceRequest) (*GetBalanceResponse, error) {
	id := req.GetAccountId()
	if id == "" {
		return nil, status.Error(codes.InvalidArgument, "account_id is required")
	}
	b, ok := s.Balances[id]
	if !ok {
		return nil, status.Errorf(codes.NotFound, "account %q not found", id)
	}
	return &GetBalanceResponse{BalanceCents: b}, nil
}

// ErrNoAccount means the account does not exist.
var ErrNoAccount = errors.New("no such account")

// Balance fetches an account's balance in cents.
func Balance(ctx context.Context, c BankServiceClient, id string) (int64, error) {
	res, err := c.GetBalance(ctx, &GetBalanceRequest{AccountId: id})
	if err != nil {
		if status.Code(err) == codes.NotFound {
			return 0, ErrNoAccount
		}
		return 0, err
	}
	return res.GetBalanceCents(), nil
}
