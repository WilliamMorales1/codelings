# sockets2: ss filters
#
# On a real server `ss -tln` prints dozens of lines. ss has its own filter
# language so you do not need grep (which also matches port 18080 when you
# look for 8080). Examples:
#     ss -tln 'sport = :22'
#     ss -tan 'dport = :443 or dport = :80'
#     ss -tn state established '( dst 10.0.0.0/8 )'
# `-H` drops the header line.
#
# The check starts a bunch of servers (TCP and UDP, on various ports and
# addresses), then runs this script and compares its output.
#
# Your task: print only the LISTENING TCP sockets whose local port is in the
# range 8000-8999, numeric, no header line. (Output format: whatever ss
# prints; the check reads the Local Address:Port column.)
#
# See what is running:  netlings sandbox sockets2

ss -tln
