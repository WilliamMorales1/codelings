#!/bin/sh
# Pretend worker that crashes after a short while.
echo "working..."
sleep 1.5
echo "segfault (pretend)" >&2
exit 139
