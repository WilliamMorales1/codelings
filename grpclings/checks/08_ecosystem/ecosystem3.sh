#!/usr/bin/env bash
# REQUIRES: protoc jq grpcurl
# HINT
# grpcurl -plaintext -d '{"sku": "mug"}' "$ADDR" shop.v1.ShopService/GetProduct
# -plaintext because the server has no TLS, -d for the request body (JSON,
# with the proto field names).
source "$GRPCLINGS_LIB"
need_file call.sh
go_check
