#!/usr/bin/env bash
# The empty sandbox behind a bare `netlings sandbox`. Not an exercise: discovery only looks in chapter dirs.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
sandbox_here "An empty sandbox with only a loopback interface (still DOWN). Try:" \
  "  ip link set lo up; ip netns add a; ip link add v0 type veth peer name v1 netns a"
