#       awk4: printf
#
#       `printf fmt, a, b` formats like C: %s string, %d integer, %.1f one
#       decimal, %-20s left-aligned in 20 columns, %8s right-aligned. Unlike
#       print, printf adds no newline: end the format with \n.
#
#       df.txt is `df -P` (sizes in KiB). Print an aligned report: a header,
#       then one row per filesystem with the mount point left-aligned in 28
#       columns, the capacity right-aligned in 4, and the free space
#       (Available / 1048576) in GiB with one decimal, right-aligned in 7:
#           MOUNT                         USE    FREE
#           /                             81%   92.2 GiB
#       Use exactly: printf "%-28s %4s %7s\n" for the header and
#                    printf "%-28s %4s %7.1f GiB\n" for the rows.
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

# TODO: a header line
NR > 1 { print $NF, $5, $4 / 1048576, "GiB" }
