#!/usr/bin/env bash
# timers6: transient timers with systemd-run

set -euo pipefail
systemd-run --user --on-active=2s --timer-property=AccuracySec=100ms \
    --unit=systemdlings-remind /usr/bin/echo "stand up and stretch"
