#!/bin/bash
# Pretend queue consumer: SIGINT means "finish up and flush", SIGTERM is ignored.
state="$(dirname "$0")/state"
trap 'echo "flushing queue"; echo flushed >"$state"; exit 0' INT
trap '' TERM
echo "consuming" 
echo running >"$state"
while :; do sleep 0.2; done
