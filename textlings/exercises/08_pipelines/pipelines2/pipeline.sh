#!/usr/bin/env bash
#       pipelines2: JSON log to a TSV report
#
#       jq turns JSON into lines (@tsv), awk aggregates the lines, sort orders
#       them. Each tool does the part it is good at.
#
#       journal.json is `journalctl -o json`. Print a tab-separated report:
#       a header line  unit<TAB>errors<TAB>warnings , then one line per
#       systemd unit (entries without _SYSTEMD_UNIT are skipped) sorted by unit
#       name, with the number of entries at PRIORITY <= 3 and == 4. Units with
#       neither still get a line with 0 0.
#
# The check runs  bash pipeline.sh journal.json  and compares stdout with
# expected.txt. Use the arguments ("$1"...), never the file names.
# The check sets LC_ALL=C, so sort compares bytes; do the same when you
# try it by hand:  LC_ALL=C bash pipeline.sh journal.json
#

jq 'select(._SYSTEMD_UNIT) | [._SYSTEMD_UNIT, .PRIORITY] | @tsv' "$1"
# TODO: count errors and warnings per unit with awk, print the header, sort
