#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# SameConfig: return proto.Equal(a, b).
# WithDefaults: out := proto.CloneOf(c) gives a deep copy (a *Config), so
# setting out.Limits.CpuMillis no longer writes into c.Limits.
source "$GRPCLINGS_LIB"
go_check
