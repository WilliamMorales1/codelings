#       awkadv3: paragraph mode, RS = ""
#
#       RS is the record separator, a newline by default. RS = "" is paragraph
#       mode: records are separated by blank lines, and a newline always acts
#       as a field separator too. With FS = "\n" every line of the block
#       becomes one field.
#
#       pacman-Qi.txt is `pacman -Qi` output: one block per package of
#       "Key : value" lines. Print the explicitly installed packages as
#           jq 1.8.2-1 736.35 KiB
#       (name, version, installed size).
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN { RS = "" }
{
    # TODO: one field per line, and only explicitly installed packages
    print $3, $6
}
