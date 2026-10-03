#       data4: string functions
#
#       length(s), substr(s, start, len), index(s, t) (position of t, 0 if
#       absent), tolower / toupper, and sub(re, repl, target) / gsub(re, repl,
#       target): sub replaces the first match, gsub every match, both in place.
#
#       users.csv is a signup export: id,name,email,phone,signup. Clean it for
#       the mailing tool: print  id,first_name,email,phone  with a header line,
#       where first_name is the name up to the first space, the email is lower
#       case, and the phone keeps only its digits.
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN { FS = OFS = "," }
NR == 1 { print "id", "first_name", "email", "phone"; next }
{
    first = $2              # TODO: only up to the first space
    email = $3              # TODO: lower case
    phone = $4
    sub(/[^0-9]/, "", phone)
    print $1, first, email, phone
}
