#       awk3: NR, NF and $NF
#
#       NR is the current line (record) number, NF the number of fields on this
#       line. $NF is the last field, $(NF-1) the one before it. A bare
#       comparison is a pattern: `NR > 1 { ... }` skips a header line.
#
#       df.txt is `df -P`. Skip the header and print, for every filesystem, its
#       capacity and mount point:
#           81% /
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).

NR > 1 { print $(NF-1), $NF }
