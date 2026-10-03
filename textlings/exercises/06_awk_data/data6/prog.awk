#       data6: OFS and rebuilding $0 with $1 = $1
#
#       Changing OFS alone does not change $0: awk only rebuilds the line from
#       its fields, joined with OFS, when you assign to a field. `$1 = $1` is
#       the idiom that forces that rebuild.
#
#       ps.txt is `ps aux`. Turn it into tab-separated values: every run of
#       blanks becomes one tab. (The COMMAND column's arguments get split too;
#       that is fine here.)
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN { OFS = "\t" }
{ print }
