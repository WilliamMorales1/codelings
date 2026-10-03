# sockets4: a TCP client in pure bash
#
# bash has a built-in TCP client: redirecting to /dev/tcp/HOST/PORT opens a
# connection (there is no such file, bash fakes it). `exec 3<>/dev/tcp/...`
# opens it as file descriptor 3 for reading and writing, then `>&3` sends and
# `<&3` receives. No netcat needed, handy on minimal servers and containers.
#
# The check runs this inside namespace a; namespace b (10.0.0.2) runs an echo
# server on port 7 that sends every line straight back.
#
# Your task: send the line `hello netlings` and print the ONE line that comes
# back. The script below does talk to the server, but it never finishes:
# `cat` reads until the other side closes the connection, and an echo server
# keeps it open, waiting for more. TCP is a stream, not a message: nothing
# tells you "that was the whole answer" unless the protocol says so.

exec 3<>/dev/tcp/10.0.0.2/7
echo "hello netlings" >&3
cat <&3
