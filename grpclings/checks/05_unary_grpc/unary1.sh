#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# At the end of greeter.proto:
#   service GreeterService {
#     rpc SayHello(SayHelloRequest) returns (SayHelloResponse);
#   }
source "$GRPCLINGS_LIB"
go_check
