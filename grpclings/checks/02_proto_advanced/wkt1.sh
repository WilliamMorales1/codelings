#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# import "google/protobuf/timestamp.proto"; and "google/protobuf/duration.proto";
# then `google.protobuf.Timestamp created_at = 2;` and
# `google.protobuf.Duration ttl = 3;`. protoc finds those files on its own.
# Expired: if either CheckValid() returns an error, it is expired; otherwise
# compare now with created_at.AsTime().Add(ttl.AsDuration()).
source "$GRPCLINGS_LIB"
go_check
