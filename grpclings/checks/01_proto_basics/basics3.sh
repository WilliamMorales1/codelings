#!/usr/bin/env bash
# REQUIRES: protoc jq
# HINT
# Add ORDER_STATUS_UNSPECIFIED = 0 as the first value of OrderStatus and
# PAYMENT_STATUS_UNSPECIFIED = 0 to PaymentStatus, then prefix every other
# value with its enum's name: PENDING becomes ORDER_STATUS_PENDING in one and
# PAYMENT_STATUS_PENDING in the other. The numbers stay the same.
source "$GRPCLINGS_LIB"
go_check
