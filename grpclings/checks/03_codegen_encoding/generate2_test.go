//go:build check

package generate2

import (
	"context"
	"testing"

	"google.golang.org/grpc"
	"grpclings/internal/check"
)

type notes struct {
	UnimplementedNoteServiceServer
}

func (notes) GetNote(_ context.Context, r *GetNoteRequest) (*GetNoteResponse, error) {
	return &GetNoteResponse{Note: &Note{Id: r.GetId(), Body: "generated code works"}}, nil
}

func TestGenerated(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterNoteServiceServer(s, notes{}) })
	res, err := NewNoteServiceClient(conn).GetNote(t.Context(), &GetNoteRequest{Id: "n1"})
	if err != nil {
		t.Fatal(err)
	}
	if res.GetNote().GetBody() != "generated code works" {
		t.Fatalf("unexpected response %v", res)
	}
}
