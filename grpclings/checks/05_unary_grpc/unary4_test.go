//go:build check

package unary4

import (
	"context"
	"errors"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"grpclings/internal/check"
)

func TestServerCodes(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) {
		RegisterBankServiceServer(s, &Server{Balances: map[string]int64{"acc-1": 1050}})
	})
	c := NewBankServiceClient(conn)
	for _, tc := range []struct {
		id   string
		want codes.Code
	}{{"acc-1", codes.OK}, {"", codes.InvalidArgument}, {"acc-404", codes.NotFound}} {
		_, err := c.GetBalance(t.Context(), &GetBalanceRequest{AccountId: tc.id})
		if got := status.Code(err); got != tc.want {
			t.Errorf("GetBalance(%q): code %v, want %v (error: %v)", tc.id, got, tc.want, err)
		}
	}
}

type otherBank struct{ UnimplementedBankServiceServer }

func (otherBank) GetBalance(_ context.Context, req *GetBalanceRequest) (*GetBalanceResponse, error) {
	switch req.GetAccountId() {
	case "gone":
		return nil, status.Error(codes.NotFound, "no such account")
	case "down":
		return nil, status.Error(codes.Unavailable, "backend not found in DNS")
	}
	return &GetBalanceResponse{BalanceCents: 7}, nil
}

func TestClientMapping(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterBankServiceServer(s, otherBank{}) })
	c := NewBankServiceClient(conn)
	if b, err := Balance(t.Context(), c, "ok"); err != nil || b != 7 {
		t.Errorf(`Balance("ok") = %d, %v`, b, err)
	}
	if _, err := Balance(t.Context(), c, "gone"); !errors.Is(err, ErrNoAccount) {
		t.Errorf(`Balance of a NotFound account: error %v, want ErrNoAccount`, err)
	}
	_, err := Balance(t.Context(), c, "down")
	if errors.Is(err, ErrNoAccount) || status.Code(err) != codes.Unavailable {
		t.Errorf(`Balance when the server is Unavailable: error %v, want the Unavailable status unchanged`, err)
	}
}
