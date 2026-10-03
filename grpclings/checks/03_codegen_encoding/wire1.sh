#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Q1: 0x08 = 0000 1000: field 1, wire type 0. 96 01: 0x96 has the top bit set,
#     so take its low 7 bits (0x16 = 22), then 0x01 shifted left by 7 (128).
# Q2: 0x12 >> 3 = 2, 0x12 & 7 = 2 (LEN); then a length byte, then ASCII.
# Q3: zigzag 3 is the fourth value of 0, -1, 1, -2, ...
# Q4: negative int32 values are sign-extended to 64 bits: always 10 varint bytes.
# Q6: 0x3f800000 is the IEEE 754 float for a very round number.
source "$GRPCLINGS_LIB"
go_check
