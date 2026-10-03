#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# `repeated Item items = 2;` turns a single item into a list, and
# `repeated string coupon_codes = 3;` adds the codes. Inside Receipt the
# name `Item` means nothing: the type is `Cart.Item`.
source "$GRPCLINGS_LIB"
go_check
