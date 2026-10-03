#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Inside the loop, before `if err != nil`:
#   if errors.Is(err, io.EOF) {
#       return stream.SendAndClose(&UploadSummary{Size: size, Sha256: hex.EncodeToString(h.Sum(nil))})
#   }
# (import "encoding/hex", "errors" and "io").
source "$GRPCLINGS_LIB"
go_check
