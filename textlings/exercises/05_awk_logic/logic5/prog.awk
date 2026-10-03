#       logic5: next
#
#       `next` stops processing the current line and moves on to the next one:
#       the usual way to filter out noise at the top of a program.
#       NF == 0 is true for a line that is empty or only blanks.
#
#       sshd_config is an OpenSSH server config. Print the settings that are
#       actually in effect as key=value, skipping comments (including indented
#       ones) and blank lines. The value is everything after the keyword:
#           Subsystem=sftp	/usr/lib/ssh/sftp-server
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

/^#/ { next }
{
    key = $1
    sub(/^[ \t]*[^ \t]+[ \t]+/, "")   # drop the keyword and blanks after it, leaving the value in $0
    print key "=" $0
}
