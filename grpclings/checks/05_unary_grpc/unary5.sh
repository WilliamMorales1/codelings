#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# lis := bufconn.Listen(1 << 20) replaces net.Listen, and the client needs
# grpc.WithContextDialer(func(ctx context.Context, _ string) (net.Conn, error) { return lis.DialContext(ctx) })
# plus the target "passthrough:///bufnet". Keep the insecure credentials.
source "$GRPCLINGS_LIB"
go_check
