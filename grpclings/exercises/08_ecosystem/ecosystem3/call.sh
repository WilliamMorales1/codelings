#!/usr/bin/env bash
# ecosystem3: calling a server from the shell
#
# grpcurl is curl for gRPC: it turns JSON into protobuf and back, learning the
# schema through server reflection (or from -proto / -protoset files).
#   grpcurl -plaintext ADDR list                       services
#   grpcurl -plaintext ADDR describe shop.v1.Product   a message
#   grpcurl -plaintext -d '{"field": "value"}' ADDR package.Service/Method
# Without -plaintext it speaks TLS, which a plaintext dev server rejects.
# Install: go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
#
# The check starts the shop (with reflection) and runs this script with ADDR
# set to its host:port. Try it yourself against any server you have running.
#
# Task: make this script print the product with SKU "mug", as JSON.
set -euo pipefail

grpcurl "$ADDR" shop.v1.ShopService/GetProduct
