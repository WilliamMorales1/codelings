#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Tail: range over s.Lines, skip non-matching levels, and
# `if err := stream.Send(line); err != nil { return err }`; return nil at the end.
# Collect: check `errors.Is(err, io.EOF)` (return what you have, nil error)
# before the generic `err != nil` case.
source "$GRPCLINGS_LIB"
go_check
