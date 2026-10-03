#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# import "google.golang.org/grpc/reflection" and call reflection.Register(s)
# after registering the shop.
source "$GRPCLINGS_LIB"
go_check
