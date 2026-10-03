#       logic1: comparison patterns, strings versus numbers
#
#       A field that looks like a number is compared numerically with a number
#       and as a *string* with a string: `$9 >= 500` is numeric, `$9 > "500"`
#       compares text, character by character.
#
#       access.log is an nginx access log (combined format): field 9 is the
#       status code, field 7 the path. Print status and path of every request
#       that failed on the server side (status 500 or above).
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).

$9 >= 500 { print $9, $7 }
