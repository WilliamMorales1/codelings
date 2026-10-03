#       logic4: range patterns
#
#       `/start/, /end/ { ... }` matches every line from one that matches start
#       through the next one that matches end, inclusive, and then looks for
#       start again. Make the patterns specific, or the range grabs more than
#       you meant.
#
#       bundle.pem is a PEM bundle as a deploy hook wrote it: comments,
#       subject/issuer lines, certificates and the private key. Print only the
#       certificates (every BEGIN CERTIFICATE ... END CERTIFICATE block, marker
#       lines included), for handing to a client that must never see the key.
#
# Checked with `gawk --posix -f prog.awk ...`, which rejects gawk-only
# extensions, so what you write here runs on any awk (mawk, busybox, BSD,
# the one true awk).

/^-----BEGIN CERTIFICATE-----$/, /^-----END CERTIFICATE-----$/
