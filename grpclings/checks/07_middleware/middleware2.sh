#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# The server reads what the client sent: metadata.FromIncomingContext, not
# FromOutgoingContext (that one is for the client's own outgoing headers).
# Reject with status.Error(codes.Unauthenticated, "..."). WithToken is
# metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+token).
source "$GRPCLINGS_LIB"
go_check
