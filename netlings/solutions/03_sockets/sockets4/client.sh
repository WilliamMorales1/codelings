# sockets4: a TCP client in pure bash
# The protocol is line-based, so read exactly one line.

exec 3<>/dev/tcp/10.0.0.2/7
echo "hello netlings" >&3
read -r reply <&3
echo "$reply"
exec 3>&-
