# sockets6: UDP has no connection
#
# UDP just fires datagrams: no handshake, no "connection refused" you can rely
# on, no delivery guarantee. Syslog, DNS, NTP, WireGuard and games use it.
# bash can send UDP too: `>/dev/udp/HOST/PORT`.
#
# The check runs this inside namespace a. Namespace b (10.0.0.2) runs a
# syslog-style collector on UDP port 5140 that writes each datagram it gets
# into a log.
#
# Your task: deliver the single message `<14>netlings: link up` to the
# collector. This version was copy-pasted from a TCP example.

echo "<14>netlings: link up" >/dev/tcp/10.0.0.2/5140
