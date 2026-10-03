#!/usr/bin/env bash
# REQUIRES: jq gawk sort
# HINT
# Without -r, @tsv output is a JSON string in quotes. Then:
# awk -F'\t' '{ seen[$1] = 1 } $2 <= 3 { err[$1]++ } $2 == 4 { warn[$1]++ }
#             END { for (u in seen) printf "%s\t%d\t%d\n", u, err[u], warn[u] }' | sort
# Print the header with printf before the pipeline, so sort never sees it.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out sh expected.txt -- journal.json
expect_out --label "same program on a second, hidden input" sh "$FIX/expected.txt" -- "$FIX/journal.json"
