#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Two mistakes: the name must be the full service name, "stock.v1.StockService"
# (package + service, as in the .proto), and retryableStatusCodes should be
# ["UNAVAILABLE"]. Codes are written in UPPER_SNAKE_CASE in service configs.
source "$GRPCLINGS_LIB"
go_check
