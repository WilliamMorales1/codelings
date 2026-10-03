#       logic3: if / else and converting strings to numbers
#
#       Inside an action you have if / else if / else, just like C. A string
#       like "81%" is not a number, so comparing it with a number compares
#       text. Adding zero converts it: "81%" + 0 is 81 (awk reads the leading
#       number and ignores the rest).
#
#       df.txt is `df -P`. For every filesystem print a status and the mount
#       point: CRIT at 90% or more, WARN at 75% or more, else ok.
#           WARN /
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).

NR > 1 {
    use = $5 + 0
    if (use >= 90) status = "CRIT"
    else if (use >= 75) status = "WARN"
    else status = "ok"
    print status, $NF
}
