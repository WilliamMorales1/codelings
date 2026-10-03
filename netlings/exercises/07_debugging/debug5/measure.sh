# debug5: measuring with ping
#
# ping's last line summarises the run:
#     rtt min/avg/max/mdev = 41.183/43.702/47.020/1.936 ms
# and the line above it has the loss:
#     10 packets transmitted, 10 received, 0% packet loss, time 1810ms
#
# The check gives the link from a to b a random delay (and a bit of jitter,
# with tc netem, as in debug4), runs this script inside a and compares its
# output with its own measurement. Print exactly two lines:
#     the average RTT in whole milliseconds (rounded down), like 43
#     the packet loss in percent, a whole number, like 0
#
# Your task: this prints the whole summary, and the wrong number from it.
# `-q` hides the per-packet lines; `awk -F/` splits on slashes.

out=$(ping -c 10 -i 0.2 -q 10.0.0.2)
echo "$out" | tail -n 1
echo "$out" | awk -F/ '/^rtt/ {print $4}'
