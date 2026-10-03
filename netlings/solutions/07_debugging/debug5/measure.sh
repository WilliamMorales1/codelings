# debug5: measuring with ping

out=$(ping -c 10 -i 0.2 -q 10.0.0.2)
echo "$out" | awk -F/ '/^rtt/ {printf "%d\n", $5}'
echo "$out" | grep -oE '[0-9.]+% packet loss' | cut -d% -f1 | cut -d. -f1
