#       awkadv1: user-defined functions
#
#       function name(a, b,    x, y) { ... return v }
#       Parameters are local; awk has no other local variables, so by
#       convention you list extra parameters after some blanks and never pass
#       them. That is how x and y above stay local. (gawk also accepts `func`;
#       POSIX awk does not. No space between name and ( when calling.)
#
#       du.txt is `du -b` output: bytes<TAB>path. Print each entry with a
#       human-readable size, right-aligned in 7 columns, two spaces, the path:
#           734.0M  ./node_modules
#       Sizes below 1024 as "512B"; otherwise divide by 1024 until below 1024
#       and print one decimal and the unit (K, M, G, T): "1.5K", "3.0G".
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

function human(n) {
    return n "B"    # TODO
}

{ printf "%7s  %s\n", human($1), $2 }
