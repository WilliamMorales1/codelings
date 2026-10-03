#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# `map<string, int32> stock_by_sku = 2;` (no `repeated`) and
# `map<string, Shelf> shelves = 3;` (the key is the location code).
# In Go: slices.Sorted(maps.Keys(w.GetStockBySku())) gives the SKUs in order.
source "$GRPCLINGS_LIB"
go_check
