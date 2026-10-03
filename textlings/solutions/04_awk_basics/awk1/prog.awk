#       awk1: fields
#
#       awk reads its input line by line, splits each line into fields on runs
#       of blanks, and runs `pattern { action }` for every line. $1 is the first
#       field, $0 the whole line. In print, a comma between items outputs a
#       space (OFS); items written side by side are concatenated with nothing
#       in between.
#
#       ps.txt is `ps aux`. Print each process's PID and the program it runs
#       (the first word of COMMAND, field 11), separated by one space.
#       The header line comes out as "PID COMMAND", which is fine.
#
#       Run: awk -f prog.awk ps.txt
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).

{ print $2, $11 }
