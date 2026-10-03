# Shared helpers for netlings checks. Source it first thing:
#   source "$NETLINGS_ROOT/checks/lib.sh"
# The check runs with cwd = the exercise directory; exit 0 means pass.
# A check that needs a network calls `sandbox` right after sourcing: that
# re-runs the whole script inside fresh user/net/mount/pid namespaces, where
# it is "root" but can only touch interfaces, routes and rules it created itself.

set -uo pipefail

: "${NETLINGS_ROOT:?run checks through netlings}"
: "${NETLINGS_BIN:?run checks through netlings}"

fail() {
  echo "FAIL: $*"
  exit 1
}

ok() { echo "ok: $*"; }

# expect_eq ACTUAL EXPECTED WHAT
expect_eq() {
  [[ "$1" == "$2" ]] || fail "$3: expected '$2', got '$1'"
  ok "$3"
}

# expect_match ACTUAL REGEX WHAT
expect_match() {
  [[ "$1" =~ $2 ]] || fail "$3: '$1' does not match /$2/"
  ok "$3"
}

need_file() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || fail "missing file $f"
  done
}

# --- read-the-output exercises -------------------------------------------

_norm() { tr '[:upper:]' '[:lower:]' | tr -d ' \t\r'; }

# answer KEY: the value after "KEY:" in answers.txt, lowercased, spaces removed.
answer() {
  local line
  line=$(grep -m1 -i "^[[:space:]]*$1[[:space:]]*:" answers.txt 2>/dev/null) || return 1
  printf '%s' "${line#*:}" | _norm
}

# expect_answer KEY SHA256 WHAT: compare against a hash, so the check does not give the answer away.
# Make the hash with:  printf %s 'value' | sha256sum
expect_answer() {
  local got
  need_file answers.txt
  got=$(answer "$1") || fail "answers.txt has no line starting with '$1:'"
  [[ -n "$got" ]] || fail "$1: still empty"
  [[ $(printf '%s' "$got" | sha256sum | cut -d' ' -f1) == "$2" ]] || fail "$1: '$got' is not right ($3)"
  ok "$1 ($3)"
}

# --- the sandbox ------------------------------------------------------------

sandbox() {
  if [[ -z ${NETLINGS_SANDBOXED:-} ]]; then
    command -v unshare >/dev/null || fail "unshare (util-linux) is not installed"
    export NETLINGS_SANDBOXED=1
    exec unshare --user --map-root-user --net --mount --pid --fork --kill-child --mount-proc \
      bash "$0" "$@"
  fi
  mount -t tmpfs -o mode=755 netlings-run /run || fail "could not mount a private /run"
  local up=/run/netlings/etc-upper
  mkdir -p "$up" /run/netlings/etc-work /run/netlings/bin
  # The real /etc files belong to the real root, so they cannot be edited in
  # place; copies in the overlay's upper layer can.
  printf '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n' >"$up/hosts"
  grep -v '^hosts:' /etc/nsswitch.conf >"$up/nsswitch.conf"
  echo 'hosts: files dns' >>"$up/nsswitch.conf"
  echo '# netlings sandbox: no nameserver configured' >"$up/resolv.conf"
  mount -t overlay netlings-etc -o "lowerdir=/etc,upperdir=$up,workdir=/run/netlings/etc-work" /etc ||
    fail "could not mount a writable /etc overlay"
  ln -s "$NETLINGS_BIN" /run/netlings/bin/netlings
  export PATH=/run/netlings/bin:$PATH
  cd "${EXERCISE_DIR:-.}" || fail "cannot enter $EXERCISE_DIR"
}

# sandbox_here [NOTE]: under `netlings sandbox NAME`, stop here and hand over a shell.
sandbox_here() {
  [[ -n ${NETLINGS_INTERACTIVE:-} ]] || return 0
  local rc=/run/netlings/bashrc
  cat >"$rc" <<'EOF'
[[ -f /etc/bash.bashrc ]] && . /etc/bash.bashrc
PS1="\[\e[36m\](netlings:${EXERCISE_NAME}${NETLINGS_NS:+ ns=$NETLINGS_NS})\[\e[0m\] \W# "
# nsh NS: a shell inside network namespace NS (exit to come back)
nsh() { NETLINGS_NS=$1 ip netns exec "$1" bash --rcfile /run/netlings/bashrc; }
EOF
  {
    echo
    echo "netlings sandbox for ${EXERCISE_NAME}: you are root in a throwaway network namespace."
    echo "Nothing here touches your real network. Type 'exit' to leave; it all disappears."
    local nss
    nss=$(ip netns list 2>/dev/null | cut -d' ' -f1 | tr '\n' ' ')
    [[ -n $nss ]] && echo "namespaces: $nss  (ip netns exec NAME CMD, ip -n NAME ..., or 'nsh NAME' for a shell)"
    [[ $# -gt 0 ]] && printf '%s\n' "$@"
    echo
  } >&2
  export EXERCISE_NAME
  exec bash --rcfile "$rc" -i
}

# run_setup [FILE [NS]]: run the learner's script with `bash -e` (inside namespace NS if given);
# show its trace if it fails. Output goes to a file so background servers it starts cannot block us.
run_setup() {
  local f=${1:-setup.sh} n=${2:-} log
  need_file "$f"
  log=$(tmpfile)
  local pre=()
  [[ -n $n ]] && pre=(ip netns exec "$n")
  "${pre[@]}" bash -ex "$f" >"$log" 2>&1 </dev/null || {
    tail -n 25 "$log" | sed 's/^/  | /'
    fail "$f stopped with an error (it runs under 'bash -e': the first failing command stops it)"
  }
  ok "$f ran without errors${n:+ (inside $n)}"
}

# capture FILE [NS]: run FILE with bash (5s limit, inside NS if given) and put its stdout in $OUT.
# Fails the check, showing stderr, if the script exits non-zero or hangs.
capture() {
  local f=$1 n=${2:-} err rc pre=()
  need_file "$f"
  err=$(tmpfile)
  [[ -n $n ]] && pre=(ip netns exec "$n")
  OUT=$("${pre[@]}" timeout 5 bash "$f" 2>"$err" </dev/null)
  rc=$?
  if [[ $rc != 0 ]]; then
    tail -n 15 "$err" | sed 's/^/  | /'
    [[ $rc == 124 ]] && fail "$f was still running after 5 seconds (waiting for input that never comes?)"
    fail "$f exited with status $rc"
  fi
}

# ns NAME CMD...: shorthand for ip netns exec.
ns() {
  local n=$1
  shift
  ip netns exec "$n" "$@"
}

# bg NAME LOG CMD...: start CMD inside namespace NAME ("-" = the sandbox itself), in the background.
bg() {
  local n=$1 log=$2
  shift 2
  if [[ $n == - ]]; then
    "$@" >"$log" 2>&1 &
  else
    ip netns exec "$n" "$@" >"$log" 2>&1 &
  fi
}

# wait_listen NAME PORT: wait until something listens on PORT (tcp or udp) inside NAME ("-" = here).
wait_listen() {
  local n=$1 port=$2 i pre=()
  [[ $n == - ]] || pre=(ip netns exec "$n")
  for ((i = 0; i < 50; i++)); do
    [[ -n $("${pre[@]}" ss -Htuln "sport = :$port" 2>/dev/null) ]] && return 0
    sleep 0.1
  done
  fail "nothing started listening on port $port in ${n}"
}

# can_ping NAME ADDR: one ping from namespace NAME ("-" = here), 1s timeout.
can_ping() {
  if [[ $1 == - ]]; then
    ping -c2 -i0.2 -W1 -q "$2" >/dev/null 2>&1
  else
    ip netns exec "$1" ping -c2 -i0.2 -W1 -q "$2" >/dev/null 2>&1
  fi
}

expect_ping() { can_ping "$1" "$2" || fail "${3:-$1 cannot ping $2}"; ok "${3:-$1 can ping $2}"; }
expect_no_ping() { can_ping "$1" "$2" && fail "${3:-$1 can ping $2, but should not}"; ok "${3:-$1 cannot ping $2}"; }

# can_tcp NAME HOST PORT: does a TCP connect succeed within a second?
can_tcp() {
  ip netns exec "$1" timeout 1 bash -c "exec 3<>/dev/tcp/$2/$3" 2>/dev/null
}

# up NAME IF...: bring interfaces up inside a namespace.
up() {
  local n=$1 i
  shift
  for i in "$@"; do ip -n "$n" link set "$i" up; done
}

# newns NAME...: create namespaces with loopback up.
newns() {
  local n
  for n in "$@"; do
    ip netns add "$n" && ip -n "$n" link set lo up
  done
}

# wire NS1 IF1 NS2 IF2: a veth pair between two namespaces, both ends up.
wire() {
  ip link add "$2" netns "$1" type veth peer name "$4" netns "$3" || fail "could not create veth $2<->$4"
  up "$1" "$2"
  up "$3" "$4"
}

addr() { ip -n "$1" addr add "$3" dev "$2" || fail "could not add $3 to $1/$2"; }

# topo_pair: a (a0 10.0.0.1/24) <-> b (b0 10.0.0.2/24)
topo_pair() {
  newns a b
  wire a a0 b b0
  addr a a0 10.0.0.1/24
  addr b b0 10.0.0.2/24
}

# topo_router [--bare]: a (10.1.0.2) <-> r (10.1.0.1 | 10.2.0.1) <-> b (10.2.0.2), all /24.
# Without --bare, r forwards and a and b have default routes via r.
topo_router() {
  newns a r b
  wire a a0 r r0
  wire b b0 r r1
  addr a a0 10.1.0.2/24
  addr r r0 10.1.0.1/24
  addr r r1 10.2.0.1/24
  addr b b0 10.2.0.2/24
  if [[ ${1:-} != --bare ]]; then
    ns r sysctl -qw net.ipv4.ip_forward=1
    ip -n a route add default via 10.1.0.1
    ip -n b route add default via 10.2.0.1
  fi
}

# topo_lan N [--no-bridge]: namespace sw with bridge br0; hosts h1..hN, each eth0 10.0.0.i/24
# wired to port pi of sw. With --no-bridge the ports exist but br0 does not.
topo_lan() {
  local i
  newns sw
  if [[ ${2:-} != --no-bridge ]]; then
    ip -n sw link add br0 type bridge
    up sw br0
  fi
  for ((i = 1; i <= $1; i++)); do
    newns "h$i"
    wire "h$i" eth0 sw "p$i"
    [[ ${2:-} == --no-bridge ]] || ip -n sw link set "p$i" master br0
    addr "h$i" eth0 "10.0.0.$i/24"
  done
  [[ ${2:-} == --no-bridge ]] || settle_bridge sw
}

# nft_json NAME ARGS...: `nft -j ARGS` inside NAME.
nft_json() {
  local n=$1
  shift
  ip netns exec "$n" nft -j "$@"
}

# load_ruleset NAME FILE: `nft -f FILE` inside NAME, failing the check with nft's message.
load_ruleset() {
  local out
  need_file "$2"
  out=$(ip netns exec "$1" nft -f "$2" 2>&1) || {
    echo "$out" | sed 's/^/  | /'
    fail "nft could not load $2"
  }
  ok "nft -f $2 loads in $1"
}

# tmpfile: a scratch file under the sandbox's private /run (or TMPDIR outside it).
tmpfile() {
  if [[ -n ${NETLINGS_SANDBOXED:-} ]]; then
    mktemp /run/netlings/tmp.XXXXXX
  else
    mktemp "${TMPDIR:-/tmp}/netlings.XXXXXX"
  fi
}

# topo_dns: the sandbox itself (host0 10.53.0.1/24) <-> namespace dns (dns0 10.53.0.53/24),
# where `netlings serve dns` answers for checks/04_dns/lab.zone. Queries are logged to $DNS_LOG.
topo_dns() {
  ip link set lo up
  newns dns
  ip link add host0 type veth peer name dns0 netns dns || fail "could not create veth"
  ip link set host0 up
  up dns dns0
  ip addr add 10.53.0.1/24 dev host0
  addr dns dns0 10.53.0.53/24
  DNS_LOG=/run/netlings/dns.log
  : >"$DNS_LOG"
  bg dns "$(tmpfile)" netlings serve dns -addr :53 -zone "$NETLINGS_ROOT/checks/04_dns/lab.zone" -log "$DNS_LOG"
  wait_listen dns 53
}

# resolves NAME: what `getent hosts` says NAME is (first address), empty if nothing.
resolves() { getent hosts "$1" | awk '{print $1; exit}'; }

# serve_ports NS PORT...: a TCP echo server on each PORT inside NS (80 and 8080 get an HTTP server).
serve_ports() {
  local n=$1 p
  shift
  for p in "$@"; do
    case $p in
      80 | 8080) bg "$n" "$(tmpfile)" netlings serve http -addr ":$p" -name "$n" ;;
      *) bg "$n" "$(tmpfile)" netlings serve echo -addr ":$p" ;;
    esac
  done
  for p in "$@"; do wait_listen "$n" "$p"; done
}

expect_tcp() { can_tcp "$1" "$2" "$3" || fail "${4:-$1 cannot connect to $2:$3}"; ok "${4:-$1 can connect to $2:$3}"; }
expect_no_tcp() { can_tcp "$1" "$2" "$3" && fail "${4:-$1 can connect to $2:$3, but should not}"; ok "${4:-$1 cannot connect to $2:$3}"; }

# topo_nat: a 10.1.0.2 --- r0 10.1.0.1 [r] r1 203.0.113.1 --- b 203.0.113.2. r forwards,
# a's default route is r, b has no route back into 10.1.0.0/24.
topo_nat() {
  newns a r b
  wire a a0 r r0
  wire r r1 b b0
  addr a a0 10.1.0.2/24
  addr r r0 10.1.0.1/24
  addr r r1 203.0.113.1/24
  addr b b0 203.0.113.2/24
  ns r sysctl -qw net.ipv4.ip_forward=1
  ip -n a route add default via 10.1.0.1
}

# settle_bridge NS: give bridge ports in NS up to 3s to reach the forwarding state
# (carrier on fresh veths comes up asynchronously).
settle_bridge() {
  local i
  for ((i = 0; i < 30; i++)); do
    [[ -z $(bridge -n "$1" -j link show | jq -r '.[] | select(.state != "forwarding") | .ifname') ]] && return 0
    sleep 0.1
  done
}

# topo_web: topo_pair plus, in b, an HTTP server on :80 (vhosts shop/blog.lab.test) and an
# HTTPS server on :443 for secure.lab.test whose CA certificate is $CA_PEM. /etc/hosts maps
# secure.lab.test to 10.0.0.2.
topo_web() {
  topo_pair
  CA_PEM=/run/netlings/ca.pem
  bg b "$(tmpfile)" netlings serve http -addr :80 -name b \
    -vhost "shop.lab.test=welcome to the shop" -vhost "blog.lab.test=welcome to the blog"
  bg b "$(tmpfile)" netlings serve https -addr :443 -name b -hosts secure.lab.test -ca-out "$CA_PEM"
  wait_listen b 80
  wait_listen b 443
  printf '10.0.0.2\tsecure.lab.test\n' >>/etc/hosts
}
