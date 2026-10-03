#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# st, err := status.New(codes.InvalidArgument, "invalid product").WithDetails(&errdetails.BadRequest{FieldViolations: violations})
# then return st.Err(). In Violations, range over status.Convert(err).Details()
# and type-assert each to *errdetails.BadRequest.
source "$GRPCLINGS_LIB"
go_check
