#!/usr/bin/env bash
# REQUIRES: bash
# HINT
# Filter the lines yourself: grep LISTEN ss.txt, grep ESTAB ss.txt | grep ':443 '.
# The java process has two sockets: one listening on 8080, one ESTAB whose
# Peer is 127.0.0.1:something. Answers are single words or numbers.
source "$NETLINGS_ROOT/checks/lib.sh"

expect_answer listener_5432 a942b37ccfaf5a813b1432caa209a43b9d144e47ad0de1549c289c253e556cd5 "process listening on 5432"
expect_answer loopback_only_port 48f599a9094eb9a4fcd2ff73dd158208d3a2e0d8769a32e3c3795fc8791a0a71 "listens on 127.0.0.1 only"
expect_answer estab_443 4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce "ESTAB lines with peer port 443 (TIME-WAIT is not established)"
expect_answer ssh_client 725b4c8929840ff6c88be48f3ea31e88d7b44485de136c65a1b90965874d17d5 "peer of the sshd connection"
expect_answer psql_state c95b7e48fd944103fc063809f920988e0f673c5b5cce5ab62392a5b95860ba79 "state of the psql socket"
expect_answer java_client_to 4aeb7ad6d5d37a041c4c5ce6562bf9e3caf05a42d931cef4d9e2a60ca623194d "java's outgoing connection"
expect_answer close_wait_process 196c23750e800642e7c008dc0416536449f295069c8161c23283c86334f8d251 "program in CLOSE-WAIT"
