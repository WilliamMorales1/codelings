#!/bin/sh
# Prints a CSV report on stdout and diagnostics on stderr.
echo "day,orders"
echo "mon,12"
echo "tue,17"
echo "note: 2 orders skipped (missing price)" >&2
