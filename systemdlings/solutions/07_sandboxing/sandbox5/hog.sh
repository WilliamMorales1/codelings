#!/bin/sh
# Pretend leaky program: reads 300 MiB into memory (tail holds the one 300 MiB "line" in RAM).
echo "loading everything into memory..."
head -c 300M /dev/zero | tail >/dev/null || exit 1
echo "survived with 300 MiB"
