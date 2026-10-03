#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Greet should return "Hello, " + name + "!": check the greeting word and
# the punctuation in exercises/00_intro/intro1/greet.go.
source "$GRPCLINGS_LIB"
go_check
