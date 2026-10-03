#!/bin/sh
# journal2: log levels from plain stdout
#
# Every journal entry has a PRIORITY, syslog style:
#   0 emerg  1 alert  2 crit  3 err  4 warning  5 notice  6 info  7 debug
# `journalctl -p warning` shows warning and worse; errors are highlighted.
# Plain output from a service is logged at info (6) - even a line that
# says "ERROR". To choose the level, start the line with "<N>" (the
# sd-daemon(3) prefix); journald strips it and stores PRIORITY=N.
#
# Task: make the "disk almost full" line a warning, and the "backup failed"
# line an error. The first line stays at info. Only edit this script.

echo "starting backup of /home"
echo "WARNING: disk almost full (93%)"
echo "ERROR: backup failed: no space left on device"
