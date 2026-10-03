# sockets3: which address does a server bind to?
#
# A listening socket is bound to an address AND a port. Bound to 0.0.0.0
# (or `*` / `[::]` in ss) it accepts connections arriving on any interface;
# bound to 127.0.0.1 only connections from the same machine. This is why a
# dev server "works on my machine" but not from the phone next to you, and
# why an admin panel accidentally on 0.0.0.0 is a security incident.
#
# The check runs this script inside namespace b, which is wired to a:
#     a: 10.0.0.1  <--->  b: 10.0.0.2
# `netlings serve echo` is a tiny TCP server bundled with the runner: it
# sends back every line it receives. `-addr HOST:PORT` says where to listen;
# a missing HOST means "all addresses".
#
# Your task: the admin port 7000 must be reachable from inside b only, never
# from a. (The public port 7001 stays open to everyone.)

netlings serve echo -addr :7000 &
netlings serve echo -addr :7001 &
