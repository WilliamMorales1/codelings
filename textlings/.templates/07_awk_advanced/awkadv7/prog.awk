# awkadv7: gensub and backreferences  (gawk only)
#
# sub and gsub modify a variable in place and cannot reuse parts of the
# match. gawk's gensub(re, repl, how, target) *returns* the new string,
# and repl may refer to parenthesised groups as \1, \2 ...
# (written "\\1" inside an awk string). `how` is "g" for all matches or a number
# for the n-th. gensub is gawk only; in POSIX awk you would use match()
# with RSTART/RLENGTH and substr.
#
# Checked with plain `gawk -f prog.awk`.
#
# access.log is an nginx access log. Field 4 looks like
# [28/Sep/2026:13:55:17. Count requests per hour and print them in
# order as
#     2026-Sep-28 13h 42
#

{
    hour = $4    # TODO: turn "[28/Sep/2026:13:55:17" into "2026-Sep-28 13h"
    n[hour]++
}
END {
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (h in n) print h, n[h]
}
