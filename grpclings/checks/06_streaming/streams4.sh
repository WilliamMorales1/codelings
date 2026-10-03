#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Replace time.Sleep with a ticker and a select:
#   select {
#   case <-stream.Context().Done():
#       return stream.Context().Err()
#   case <-ticker.C:
#   }
# and `if err := stream.Send(...); err != nil { return err }`.
# The check uses a long interval, so waiting out the sleep is too slow.
source "$GRPCLINGS_LIB"
go_check
