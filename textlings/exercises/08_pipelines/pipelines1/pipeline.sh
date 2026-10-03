#!/usr/bin/env bash
#       pipelines1: top talkers from an access log
#
#       The classic: extract a column, sort, count adjacent duplicates with
#       `uniq -c`, sort the counts numerically, keep the top. uniq only merges
#       *adjacent* equal lines, so it needs sorted input.
#
#       Print the 5 client IPs with the most requests as  count ip , most first,
#       ties broken by IP (plain byte order, as `sort` does in the C locale):
#           14 203.0.113.7
#
# The check runs  bash pipeline.sh access.log  and compares stdout with
# expected.txt. Use the arguments ("$1"...), never the file names.
# The check sets LC_ALL=C, so sort compares bytes; do the same when you
# try it by hand:  LC_ALL=C bash pipeline.sh access.log
#

cut -d' ' -f1 "$1" | uniq -c | sort -r | head -5
