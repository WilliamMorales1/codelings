# journal3: journalctl -o json and jq
#
# `journalctl -o json` prints one JSON object per entry: every field, not
# just the message. That is the reliable way to feed logs into scripts:
#   journalctl --user -u NAME -o json | jq -r 'FILTER'
# All field values are strings. PRIORITY is "4", not 4, and in jq a
# string compared with a number is always greater, so `.PRIORITY <= 4` is
# false for every entry.
#
# Task: this jq program gets the service's entries (one JSON object at a
# time) and should print "PRIORITY MESSAGE" for every entry at warning (4)
# or worse, e.g. "4 slow query: 2.3s". Fix the filter. The check runs:
#   jq -r -f problems.jq
#

select(.PRIORITY <= 4) | "\(.PRIORITY) \(.MESSAGE)"
