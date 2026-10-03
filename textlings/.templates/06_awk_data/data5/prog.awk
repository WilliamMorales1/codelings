#       data5: joining two files with FNR == NR
#
#       With two input files, NR keeps counting across both while FNR restarts
#       at 1 for each file. So `FNR == NR { ...; next }` runs only for the
#       first file: load it into an array, and `next` keeps those lines away
#       from the rules below.
#
#       The check runs  awk -f prog.awk customers.csv orders.csv .
#       Print every order with its customer's name and tier instead of the id,
#       and UNKNOWN (tier -) for an id that is not in customers.csv:
#           order_id,customer,tier,usd
#           o100,Acme Corp,gold,212.07
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN { FS = OFS = "," }
FNR == NR { name[$1] = $2; tier[$1] = $3 }
FNR == 1 { print "order_id", "customer", "tier", "usd"; next }
{ print $1, name[$2], tier[$2], $3 }
