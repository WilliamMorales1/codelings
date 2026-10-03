#       logic2: regex matching with ~ and !~
#
#       `$7 ~ /re/` is true when field 7 matches the regular expression;
#       `!~` is the opposite. `/re/` alone as a pattern matches against $0.
#       Combine conditions with && || !.
#
#       passwd is an /etc/passwd. Print the human accounts: uid (field 3)
#       between 1000 and 60000, and a shell that is not nologin or false,
#       wherever those live (/usr/bin/nologin, /sbin/nologin, /bin/false ...):
#           learner1 /bin/bash
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).

BEGIN { FS = ":" }
$3 >= 1000 && $3 <= 60000 && $7 !~ /\/(nologin|false)$/ { print $1, $7 }
