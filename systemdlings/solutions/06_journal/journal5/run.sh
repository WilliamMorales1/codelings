#!/usr/bin/env bash
# journal5: systemd-cat - journal logging for things that are not units

set -euo pipefail
cd "$(dirname "$0")"
systemd-cat -t systemdlings-nightly --stderr-priority=err sh job.sh
