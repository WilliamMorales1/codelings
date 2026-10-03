# advanced6: --slurp, limit and first
#
# -s (--slurp) reads the whole input stream into one array first: simple,
# but it holds everything in memory (fine for a day of logs, not for a
# year). `limit(n; f)` stops f after n outputs; `first(f)` is limit(1; f).
#
# journal.json is `journalctl -o json`. Print the first three entries at
# err level or worse (PRIORITY <= 3) as  unit: message , then a last line
# "entries: N" with the total number of journal entries.
#

(.[] | select(.PRIORITY | tonumber <= 3) | "\(._SYSTEMD_UNIT): \(.MESSAGE)"),
"entries: \(length)"
