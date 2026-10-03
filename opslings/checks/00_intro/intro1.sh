#!/usr/bin/env bash
# REQUIRES: bash
# HINT
# Make the last line of exercises/00_intro/intro1/welcome.txt read
# exactly `status: ready for duty`, then save the file.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file welcome.txt
grep -qx 'status: ready for duty' welcome.txt || fail "welcome.txt should say 'status: ready for duty'"
ok "welcome.txt says you are ready"
