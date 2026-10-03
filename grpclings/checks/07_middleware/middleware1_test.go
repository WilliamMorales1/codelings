//go:build check

package middleware1

import (
	"bytes"
	"context"
	"encoding/json"
	"log/slog"
	"strings"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"grpclings/internal/check"
)

type pinger struct{ UnimplementedPingServiceServer }

func (pinger) Ping(_ context.Context, r *PingRequest) (*PingResponse, error) {
	if c := codes.Code(r.GetFailWithCode()); c != codes.OK {
		return nil, status.Error(c, "as requested")
	}
	return &PingResponse{}, nil
}

func TestLogging(t *testing.T) {
	var buf bytes.Buffer
	logger := slog.New(slog.NewJSONHandler(&buf, nil))
	conn := check.Serve(t, func(s *grpc.Server) { RegisterPingServiceServer(s, pinger{}) },
		grpc.ChainUnaryInterceptor(Logging(logger)))
	c := NewPingServiceClient(conn)

	if _, err := c.Ping(t.Context(), &PingRequest{}); err != nil {
		t.Fatalf("Ping: %v (the interceptor must return what the handler returned)", err)
	}
	_, err := c.Ping(t.Context(), &PingRequest{FailWithCode: int32(codes.NotFound)})
	if status.Code(err) != codes.NotFound {
		t.Fatalf("Ping(fail NotFound): %v, want the NotFound status passed through", err)
	}

	lines := strings.Split(strings.TrimSpace(buf.String()), "\n")
	if len(lines) != 2 {
		t.Fatalf("want 2 log records, got %d:\n%s", len(lines), buf.String())
	}
	for i, want := range []string{"OK", "NotFound"} {
		var rec map[string]any
		if err := json.Unmarshal([]byte(lines[i]), &rec); err != nil {
			t.Fatal(err)
		}
		if rec["msg"] != "rpc" || rec["level"] != "INFO" {
			t.Errorf("record %d: want level INFO, msg \"rpc\": %s", i, lines[i])
		}
		if rec["method"] != "/ping.v1.PingService/Ping" {
			t.Errorf("record %d: method = %v", i, rec["method"])
		}
		if rec["code"] != want {
			t.Errorf("record %d: code = %v, want %s", i, rec["code"], want)
		}
		if _, ok := rec["duration"].(float64); !ok {
			t.Errorf("record %d: duration should be a time.Duration, got %v", i, rec["duration"])
		}
	}
}
