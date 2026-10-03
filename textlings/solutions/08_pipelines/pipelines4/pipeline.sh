#!/usr/bin/env bash
#       pipelines4: stars per language
#
#       repos.json is `gh api orgs/acme/repos`. Ignoring archived repos, print
#       the total stars per language (repos without a language count as
#       "none") as  stars repos language , most stars first, top 3 only:
#           4521 3 Go
#
# The check runs  bash pipeline.sh repos.json  and compares stdout with
# expected.txt. Use the arguments ("$1"...), never the file names.
# The check sets LC_ALL=C, so sort compares bytes; do the same when you
# try it by hand:  LC_ALL=C bash pipeline.sh repos.json

jq -r '.[] | select(.archived | not) | [.language // "none", .stargazers_count] | @tsv' "$1" \
  | awk -F'\t' '{ stars[$1] += $2; n[$1]++ } END { for (l in stars) print stars[l], n[l], l }' \
  | sort -k1,1nr \
  | head -3
