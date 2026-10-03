// ecosystem1: the standard health checking service
//
// Load balancers, Kubernetes probes and grpc-health-probe all speak one
// protocol, grpc.health.v1.Health: Check(service name) answers SERVING,
// NOT_SERVING, or the status NotFound when the name is unknown. The empty
// name "" means the server as a whole. grpc-go ships an implementation in
// google.golang.org/grpc/health; you register it and keep its statuses
// up to date with SetServingStatus.
//
// Task:
//  1. Setup must mark "shop.v1.ShopService" (and the server as a whole)
//     SERVING; right now a probe for the service gets NotFound.
//  2. Drain, called at the start of a graceful shutdown, must flip every
//     status to NOT_SERVING so load balancers stop sending new traffic.
package ecosystem1

import (
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
)

// Setup registers the shop and the health service on s.
func Setup(s *grpc.Server) *health.Server {
	RegisterShopServiceServer(s, Shop{})
	h := health.NewServer()
	healthpb.RegisterHealthServer(s, h)
	h.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)
	h.SetServingStatus(ShopService_ServiceDesc.ServiceName, healthpb.HealthCheckResponse_SERVING)
	return h
}

// Drain marks everything NOT_SERVING.
func Drain(h *health.Server) {
	// Shutdown sets every status to NOT_SERVING and ignores later updates.
	h.Shutdown()
}
