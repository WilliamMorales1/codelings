#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# In the proto:
#   oneof method {
#     Card card = 3;
#     string iban = 4;
#     bool cash = 5;
#   }
# In Go, add `case *Payment_Iban:` (the string is m.Iban) and `case *Payment_Cash:`.
source "$GRPCLINGS_LIB"
go_check
