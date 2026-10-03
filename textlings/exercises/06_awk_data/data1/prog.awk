#       data1: associative arrays and counting
#
#       awk arrays are hashes keyed by strings: `n[$9]++` counts per status.
#       `for (k in n)` visits every key, in an *unspecified* order (it differs
#       between awks and even runs), so the check sorts your output. For a
#       fixed order, pipe to sort (chapter 07).
#
#       access.log is an nginx access log. Print how many requests got each
#       status code:  status count , one per line.
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

{ n[$9] = 1 }
END { for (s in n) print s, n[s] }
