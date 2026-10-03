#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Add `UnimplementedInventoryServiceServer` as the first (embedded) field of
# Server. In AddItem: lock s.mu, store a clone of req.GetItem() under its SKU,
# and return &AddItemResponse{Item: ...}. Returning a nil response with a nil
# error is not allowed: gRPC cannot send "nothing".
source "$GRPCLINGS_LIB"
go_check
