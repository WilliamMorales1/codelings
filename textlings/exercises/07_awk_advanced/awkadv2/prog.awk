#       awkadv2: a printf report, sorted with a pipe, and close()
#
#       `print ... | "sort -k4,4nr"` sends lines to one sort process that
#       stays open until the program ends, and sort prints nothing until its
#       input is closed. So whether a line you print afterwards lands before or
#       after the sorted rows depends on the awk and on buffering: in a
#       terminal, gawk shows TOTAL on top. `close("sort -k4,4nr")` (the exact
#       same string) ends the pipe and waits for sort to finish, which makes
#       the order certain. The check wants the right output *and* a close().
#
#       ci.csv is a CI export: pipeline,job,status,seconds. Print a report:
#       header, one row per job sorted by average duration (slowest first),
#       then a TOTAL row over all runs:
#           JOB              RUNS  FAIL    AVG(s)
#           integration         6     2     612.3
#           ...
#           TOTAL              30     7     401.2
#       Formats: "%-15s %5s %5s %9s\n" for the header,
#                "%-15s %5d %5d %9.1f\n" for rows and TOTAL.
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN { FS = ","; printf "%-15s %5s %5s %9s\n", "JOB", "RUNS", "FAIL", "AVG(s)" }
NR > 1 {
    runs[$2]++; secs[$2] += $4; total += $4
    if ($3 != "success") { fails[$2]++; nfail++ }
}
END {
    for (j in runs)
        printf "%-15s %5d %5d %9.1f\n", j, runs[j], fails[j], secs[j] / runs[j] | "sort -k4,4nr"
    printf "%-15s %5d %5d %9.1f\n", "TOTAL", NR - 1, nfail, total / (NR - 1)
}
