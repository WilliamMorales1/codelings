#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# The procedure is the full gRPC path: "/shop.v1.ShopService/GetProduct".
# For the unknown SKU, wrap the error:
#   connect.NewError(connect.CodeNotFound, fmt.Errorf(...))
source "$GRPCLINGS_LIB"
go_check
