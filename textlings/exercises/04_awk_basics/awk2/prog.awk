#       awk2: the field separator
#
#       By default fields are separated by blanks. Set FS to split on something
#       else. `awk -F: ...` on the command line and `BEGIN { FS = ":" }` in the
#       program do the same thing; BEGIN runs once, before the first line.
#
#       passwd is an /etc/passwd: user:password:uid:gid:gecos:home:shell.
#       Print every user's name and login shell, separated by a space.
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

{ print $1, $7 }
