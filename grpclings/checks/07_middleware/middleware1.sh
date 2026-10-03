#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# start := time.Now(); resp, err := handler(ctx, req); then
# logger.InfoContext(ctx, "rpc", "method", info.FullMethod,
#     "code", status.Code(err).String(), "duration", time.Since(start))
# and return resp, err. status.Code(nil) is codes.OK.
source "$GRPCLINGS_LIB"
go_check
