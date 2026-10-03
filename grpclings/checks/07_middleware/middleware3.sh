#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
#   type authedStream struct {
#       grpc.ServerStream
#       ctx context.Context
#   }
#   func (s *authedStream) Context() context.Context { return s.ctx }
# then pass &authedStream{ServerStream: ss, ctx: ctx} to handler, where ctx is
# the context.WithValue result the code currently throws away.
source "$GRPCLINGS_LIB"
go_check
