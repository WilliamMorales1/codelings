#!/usr/bin/env bash
# journal5: systemd-cat - journal logging for things that are not units
#
# Not everything runs as a unit: cron jobs, hooks, a script you start by
# hand. `systemd-cat` connects a command's stdout/stderr to the journal,
# just like a service's:
#   systemd-cat -t NAME CMD...              identifier NAME, priority info
#   systemd-cat -p warning CMD...           priority for stdout
#   systemd-cat --stderr-priority=err CMD   a separate priority for stderr
#   echo hi | systemd-cat -t NAME           or as the end of a pipe
# Then `journalctl --user -t NAME` finds it.
#
# (A note on the user manager: LogLevelMax= and LogExtraFields= in a *user*
# unit only apply to the manager's own messages about the unit, not to the
# service's output, because journald reads those settings for system units
# only. For user services, filter at the source or with journalctl.)
#
# Task: run job.sh (next to this script) so that its output lands in the
# journal under the identifier "systemdlings-nightly", stdout at info and
# stderr at err. The check runs this script and reads the journal.

set -euo pipefail
cd "$(dirname "$0")"
sh job.sh
