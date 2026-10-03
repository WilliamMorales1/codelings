//go:build check

package ecosystem1

import (
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"grpclings/internal/check"
)

func TestHealth(t *testing.T) {
	var h *health.Server
	conn := check.Serve(t, func(s *grpc.Server) { h = Setup(s) })
	c := healthpb.NewHealthClient(conn)
	for _, svc := range []string{"", "shop.v1.ShopService"} {
		res, err := c.Check(t.Context(), &healthpb.HealthCheckRequest{Service: svc})
		if err != nil || res.GetStatus() != healthpb.HealthCheckResponse_SERVING {
			t.Errorf("Check(%q) = %v, %v; want SERVING", svc, res.GetStatus(), err)
		}
	}
	Drain(h)
	for _, svc := range []string{"", "shop.v1.ShopService"} {
		res, err := c.Check(t.Context(), &healthpb.HealthCheckRequest{Service: svc})
		if err != nil || res.GetStatus() != healthpb.HealthCheckResponse_NOT_SERVING {
			t.Errorf("after Drain, Check(%q) = %v, %v; want NOT_SERVING", svc, res.GetStatus(), err)
		}
	}
}
