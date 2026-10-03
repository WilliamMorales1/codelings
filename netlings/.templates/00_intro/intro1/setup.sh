# intro1: welcome to netlings
#
# Nearly every exercise is a directory with a setup.sh (commands) or a config
# file in it. The check starts a brand-new sandbox: a user + network namespace
# where you are "root", but only over interfaces, routes and firewall rules
# that exist inside it. Your real network is never touched. The check runs
# your file in there with `bash -e`, then tests what the network looks like.
# When the check passes, the exercise is done and netlings moves on.
#
# A fresh network namespace has one interface, `lo`, and it is DOWN, so not even
# `ping 127.0.0.1` works. The line below is meant to fix that, but it sets the
# wrong state. Fix it and save.
#
# To poke around yourself:   netlings sandbox intro1
# (in there, try `ip link`, `ping -c1 127.0.0.1`, then `bash setup.sh` and again.)

ip link set lo down
