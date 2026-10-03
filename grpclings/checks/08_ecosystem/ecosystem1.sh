#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# h.SetServingStatus("shop.v1.ShopService", healthpb.HealthCheckResponse_SERVING)
# (ShopService_ServiceDesc.ServiceName holds that name), and the same for "".
# Drain: h.Shutdown() flips everything to NOT_SERVING (and ignores later
# SetServingStatus calls, which is what you want during shutdown).
source "$GRPCLINGS_LIB"
go_check
