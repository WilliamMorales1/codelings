//go:build check

package unary3

import (
	"context"
	"net"
	"testing"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type weather struct {
	UnimplementedWeatherServiceServer
	sawDeadline chan bool
}

func (w weather) GetForecast(ctx context.Context, req *GetForecastRequest) (*GetForecastResponse, error) {
	_, ok := ctx.Deadline()
	w.sawDeadline <- ok
	if req.GetCity() == "Slowtown" {
		select {
		case <-ctx.Done():
			return nil, status.FromContextError(ctx.Err()).Err()
		case <-time.After(5 * time.Second):
		}
	}
	return &GetForecastResponse{City: req.GetCity(), HighC: 21.5}, nil
}

func TestForecast(t *testing.T) {
	lis, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	srv := grpc.NewServer()
	w := weather{sawDeadline: make(chan bool, 10)}
	RegisterWeatherServiceServer(srv, w)
	go srv.Serve(lis)
	defer srv.Stop()

	conn, err := Dial(lis.Addr().String())
	if err != nil {
		t.Fatalf("Dial: %v", err)
	}
	defer conn.Close()
	c := NewWeatherServiceClient(conn)

	res, err := Forecast(t.Context(), c, "Lisbon")
	if err != nil || res.GetHighC() != 21.5 {
		t.Fatalf("Forecast(Lisbon) = %v, %v", res, err)
	}
	if !<-w.sawDeadline {
		t.Error("the server saw no deadline: set one on the context")
	}

	start := time.Now()
	_, err = Forecast(t.Context(), c, "Slowtown")
	took := time.Since(start)
	if status.Code(err) != codes.DeadlineExceeded {
		t.Errorf("Forecast(Slowtown) error = %v, want code DeadlineExceeded", err)
	}
	if took > time.Second {
		t.Errorf("Forecast(Slowtown) took %s, want about 300ms", took.Round(time.Millisecond))
	}
}
