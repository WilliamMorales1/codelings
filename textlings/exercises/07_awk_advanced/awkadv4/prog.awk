#       awkadv4: getline, carefully
#
#       `(getline line < file)` reads the next line of file into `line` and
#       returns 1, 0 at end of file, and -1 if the file cannot be read. -1 is
#       true, so `while (getline line < file)` spins forever on a missing file:
#       always compare with > 0.
#
#       The check runs  awk -v hosts=hosts.txt -f prog.awk access.log .
#       Load the "ip name" pairs from the hosts file in BEGIN, skipping
#       comments, then print  ip host path  for each request, with "-" for
#       unknown IPs. It is also run with a hosts file that does not exist: then
#       every host is "-" and the program must still finish.
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).
#

BEGIN {
    while (getline line < hosts) {
        if (line ~ /^#/) continue
        split(line, f, " ")
        name[f[1]] = f[2]
    }
}
{ print $1, (($1 in name) ? name[$1] : "-"), $7 }
