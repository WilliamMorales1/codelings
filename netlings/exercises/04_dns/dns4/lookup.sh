# dns4: asking DNS directly with dig
#
# getent answers "what would a program get?". dig answers "what does DNS
# say?": record types, TTLs, which server answered. It talks to the servers in
# /etc/resolv.conf unless you say `dig @SERVER ...`.
#
#     dig NAME TYPE        full answer (TYPE defaults to A)
#     dig +short NAME TYPE just the data
#     dig -x ADDRESS       reverse lookup (PTR record)
#     dig +noall +answer NAME   only the answer lines: name TTL class type data
#
# The check points /etc/resolv.conf at the lab DNS server (10.53.0.53), runs
# this script and compares its output, one line per question:
#   1. the mail server of lab.test          expected like: 10 mail.lab.test.
#   2. the TXT record of _verify.lab.test   with its quotes, as dig prints it
#   3. the name that 10.53.0.80 points back to
#   4. the TTL, in seconds, of api.lab.test's A record (just the number)
#
# Every line below asks the wrong thing or prints too much. Fix them.
# Experiment first:  netlings sandbox dns4

dig +short lab.test
dig +short _verify.lab.test
dig +short 10.53.0.80
dig api.lab.test
