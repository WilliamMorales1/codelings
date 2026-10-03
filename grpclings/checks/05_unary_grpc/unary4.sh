#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Server: status.Error(codes.InvalidArgument, "...") and
# status.Errorf(codes.NotFound, "account %q not found", id), from
# google.golang.org/grpc/status and google.golang.org/grpc/codes.
# Client: `if status.Code(err) == codes.NotFound { return 0, ErrNoAccount }`.
# The check's own server says "no such account", not "not found".
source "$GRPCLINGS_LIB"
go_check
