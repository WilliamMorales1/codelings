#!/usr/bin/env bash
# timers6: transient timers with systemd-run
#
# No unit files at all: `systemd-run` asks the manager to create a
# *transient* service (and, with a timer option, a transient timer) that
# lives until it has run. It is `at` and `sleep 600 && cmd &` done properly:
# the job runs in its own cgroup, logs to the journal, and shows up in
# `systemctl --user list-timers`.
#   systemd-run --user --on-active=30s --unit=NAME CMD...    in 30 seconds
#   systemd-run --user --on-calendar='*:0/5' CMD...           every 5 minutes
#   --timer-property=AccuracySec=100ms                        precise timing
# Always pass --user here: without it systemd-run talks to the *system*
# manager and asks for a password.
#
# Task: complete the command so that, 2 seconds after this script runs, a
# transient unit named systemdlings-remind logs "stand up and stretch".
# Use /usr/bin/echo, and make the timer precise (AccuracySec=100ms). The
# check runs this script and waits for the reminder.

set -euo pipefail
# TODO: systemd-run ...
