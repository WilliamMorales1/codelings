#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Dial: grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
# with "google.golang.org/grpc/credentials/insecure".
# Forecast: ctx, cancel := context.WithTimeout(ctx, 300*time.Millisecond);
# defer cancel(); then make the call with the new ctx.
source "$GRPCLINGS_LIB"
go_check
