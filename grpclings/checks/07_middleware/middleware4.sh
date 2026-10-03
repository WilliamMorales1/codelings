#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# GetPrice: name the first parameter ctx and pass it straight to
# f.Backend.GetPrice; drop the Background/WithTimeout lines.
# DefaultTimeout: `if _, ok := ctx.Deadline(); !ok { ctx, cancel = context.WithTimeout(ctx, d); defer cancel() }`
# before calling invoker.
source "$GRPCLINGS_LIB"
go_check
