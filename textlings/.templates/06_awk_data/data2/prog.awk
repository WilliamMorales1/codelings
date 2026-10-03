#       data2: grouping and summing a CSV
#
#       Same idea as counting, but add a field instead of 1: `sum[$3] += $5`.
#       This only works on CSV without quoted fields (for those see awkadv5).
#
#       costs.csv is a cloud billing export: date,account,service,region,usd.
#       Print the total cost per service with two decimals:
#           EC2 123.45
#       (order does not matter; the check sorts).
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

NR > 1 { sum[$3] += $5 }
END { for (s in sum) print s, sum[s] }   # TODO: two decimals
