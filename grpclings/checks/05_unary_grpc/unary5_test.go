//go:build check

package unary5

import (
	"context"
	"fmt"
	"sync"
	"testing"

	"google.golang.org/grpc"
)

type echo struct {
	UnimplementedEchoServiceServer
	prefix string
}

func (e echo) Echo(_ context.Context, r *EchoRequest) (*EchoResponse, error) {
	return &EchoResponse{Text: e.prefix + r.GetText()}, nil
}

func TestManyHarnesses(t *testing.T) {
	var wg sync.WaitGroup
	for i := range 4 {
		wg.Go(func() {
			prefix := fmt.Sprintf("server %d: ", i)
			conn, stop, err := Start(func(s *grpc.Server) { RegisterEchoServiceServer(s, echo{prefix: prefix}) })
			if err != nil {
				t.Errorf("harness %d: Start: %v", i, err)
				return
			}
			defer stop()
			res, err := NewEchoServiceClient(conn).Echo(t.Context(), &EchoRequest{Text: "hi"})
			if err != nil {
				t.Errorf("harness %d: Echo: %v", i, err)
				return
			}
			if res.GetText() != prefix+"hi" {
				t.Errorf("harness %d talked to the wrong server: %q", i, res.GetText())
			}
		})
	}
	wg.Wait()
}
