#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# outbox := r.join(); defer r.leave(outbox). Start a goroutine that loops on
# stream.Recv() and calls r.broadcast(m), reporting io.EOF (as nil) or any
# other error on a `recvErr := make(chan error, 1)`. The handler itself loops
# on a select: a message from outbox -> stream.Send it; a value from recvErr ->
# return it. Only the handler goroutine calls Send.
source "$GRPCLINGS_LIB"
go_check
