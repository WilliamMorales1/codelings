#!/usr/bin/env bash
# Pretend weather API: slow and rate-limited. Don't edit this file.
sleep 0.2
[[ -n "${API_LOG:-}" ]] && echo "$1" >>"$API_LOG"
echo "forecast for $1: sunny, 21C"
