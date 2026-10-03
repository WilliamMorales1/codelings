# awkadv6: ordered for-in with PROCINFO["sorted_in"]  (gawk only)
#
# POSIX awk's for-in order is unspecified. gawk lets you choose it:
# PROCINFO["sorted_in"] = "@val_num_desc" walks by value, largest first
# (ties by index); "@ind_str_asc" by key. gawk also has asort() and
# asorti() to sort an array into another. None of this exists in POSIX
# awk, where you pipe to sort instead (awkadv2).
#
# Checked with plain `gawk -f prog.awk`.
#
# access.log is an nginx access log. Print the requests per client IP,
# busiest first:  count ip

{ n[$1]++ }
END {
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (ip in n) print n[ip], ip
}
