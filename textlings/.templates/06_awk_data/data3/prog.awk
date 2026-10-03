#       data3: split
#
#       `n = split(s, parts, ",")` splits s on commas into parts[1] .. parts[n]
#       and returns n. `(k in arr)` tests for a key without creating it.
#
#       group is an /etc/group: name:password:gid:member,member,...
#       Invert it: for every user that appears as a member, print the groups
#       they belong to, comma-separated, in file order:
#           learner1: wheel,docker,video,audio
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN { FS = ":" }
{ groups[$4] = groups[$4] "," $1 }
END { for (u in groups) print u ": " groups[u] }
