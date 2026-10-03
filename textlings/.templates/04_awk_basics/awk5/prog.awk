#       awk5: BEGIN and END, accumulating
#
#       END runs once after the last line: the place to print totals. Variables
#       need no declaration and start as 0 / "". NR in END is the total number
#       of lines read, header included.
#
#       ps.txt is `ps aux`. RSS (field 6) is resident memory in KiB. Print
#       exactly two lines:
#           processes: 14
#           total RSS: 4521.3 MiB
#       (not counting the header; MiB with one decimal).
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

{ total += $6 }
END {
    print "processes:", NR
    print "total RSS:", total / 1024, "MiB"
}
