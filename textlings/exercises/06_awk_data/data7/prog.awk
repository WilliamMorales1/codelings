#       data7: editing a field in place, and -v
#
#       Assigning to a field rebuilds $0 with OFS between the fields, so when
#       FS is ":" you want OFS to be ":" as well, or the output is no longer a
#       valid passwd file. `-v name=value` sets an awk variable from the
#       command line before BEGIN runs.
#
#       The check runs  awk -v user=deploy -f prog.awk passwd .
#       Print passwd back unchanged, except that the given user's shell becomes
#       /usr/bin/nologin (locking the account).
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN { FS = ":" }
$1 == "deploy" { $7 = "/usr/bin/nologin" }
{ print }
