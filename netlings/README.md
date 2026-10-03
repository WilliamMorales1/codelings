# netlings

Small hands-on exercises for **Linux networking**: interfaces, routing,
sockets, DNS, nftables, bridges and VLANs, debugging, HTTP and TLS.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a directory with a broken `setup.sh`, config file or
script in it. You fix it and save; once the check passes the exercise
is done and the runner moves you on to the next one.

**Your real network is never touched.** Each check runs inside a throwaway
unprivileged user + network + mount + pid namespace (`unshare -r -n -m -p`).
In there you are "root", but only over interfaces, routes, firewall rules
and `/etc` files that exist inside it; everything disappears when the check
ends. No sudo, no Docker, no VMs. Topologies with several hosts are built
with `ip netns add` and veth pairs inside that sandbox, so the commands you
learn are the real ones.

## Setup

**Linux only.** You need a kernel that allows unprivileged user namespaces,
Go 1.27+ to build the runner, and the usual networking tools.

Arch:

```sh
sudo pacman -S go iproute2 iputils nftables util-linux curl jq openssl
sudo pacman -S bind tcpdump                                  # one exercise each
sudo pacman -S socat openbsd-netcat traceroute ethtool       # optional, for the sandbox
```

Debian/Ubuntu:

```sh
sudo apt install golang iproute2 iputils-ping iputils-tracepath nftables util-linux curl jq openssl
sudo apt install dnsutils tcpdump
sudo apt install socat netcat-openbsd traceroute ethtool
```

Fedora:

```sh
sudo dnf install golang iproute iputils nftables util-linux curl jq openssl
sudo dnf install bind-utils tcpdump
sudo dnf install socat netcat traceroute ethtool
```

If your package manager's Go is older than 1.27, get it from [go.dev/dl](https://go.dev/dl/).
`dig` comes from `bind`/`dnsutils`/`bind-utils`; `ip`, `ss`, `tc` and `bridge`
from `iproute2`; `ping` and `tracepath` from `iputils`.

Ubuntu 24.04+ blocks unprivileged user namespaces through AppArmor. For the
course, allow them with `sudo sysctl kernel.apparmor_restrict_unprivileged_userns=0`
(resets on reboot).

Then build the runner and check your system:

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/netlings
go build -o netlings .
./netlings doctor
```

`doctor` lists each tool, which chapters need it, the package for
anything missing, and whether unprivileged namespaces work. If they do not,
check `sysctl kernel.unprivileged_userns_clone` (must be 1).

## Usage

```sh
netlings watch            # the main loop: re-checks every time you save
netlings                  # check once, stop at the first unsolved exercise
netlings list             # every exercise and its status
netlings run routing2     # check one exercise by name
netlings hint routing2    # print its hint
netlings sandbox routing2 # a root shell inside the exercise's network
netlings solution routing2
netlings reset routing2   # back to the original, unsolved files
```

```sh
# fish: put the runner on your PATH
set -gx PATH $PWD $PATH
netlings watch
```

Open a second terminal with `netlings watch` running, edit the file it
points at, and save. The `File:` line is an OSC 8 hyperlink (clickable in
kitty, foot, WezTerm, Ghostty, recent VTE...). `NO_COLOR=1` turns colour and
links off.

### The sandbox

`netlings sandbox NAME` builds exactly the network the check starts from
(namespaces, cables, servers) and drops you into a bash shell inside it, in
the exercise directory. Experiment freely: `ip netns list`, `ip -n a addr`,
`ip netns exec a ping 10.0.0.2`, `nsh a` for a shell inside namespace `a`,
`bash setup.sh` to try your file. `exit` and it is all gone. A bare
`netlings sandbox` gives an empty one.

The checks' servers are built into the runner, so nothing else needs to be
installed: `netlings serve http|https|echo|udp|dns` (see
`netlings serve -h`). You can use them in the sandbox too.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, the sandbox |
| `01_interfaces` | link state vs. addresses, prefix lengths and connected routes, MTU mismatch, reading `ip addr` |
| `02_routing` | namespaces and veth pairs, on-link gateways, `ip_forward` per namespace, static routes both ways, longest prefix match |
| `03_sockets` | reading `ss`, ss filters, bind addresses, bash `/dev/tcp` and `/dev/udp`, finding the PID behind a port |
| `04_dns` | `/etc/hosts`, `resolv.conf` nameserver and search, `dig` record types, `nsswitch.conf` order, per-namespace `/etc/netns` |
| `05_firewall` | nftables base chains, rule order, counters, sets, masquerade, DNAT port forwarding, conntrack state |
| `06_bridge_vlan` | Linux bridge, ARP / neighbour table, VLAN subinterfaces, VLAN-aware bridge |
| `07_debugging` | reading tcpdump output, BPF capture filters, tracing a routing loop, `tc netem` delay, measuring with ping |
| `08_http` | `curl -v` anatomy, headers, virtual hosts and `--resolve`, redirects and `-w`, `openssl s_client`, `--cacert` vs `-k`, POSTing JSON |

45 exercises. Some are "read the output" ones: real captured `ip`, `ss`,
`tcpdump` or `curl -v` output, with questions to answer in `answers.txt`.
The checks store only hashes of those answers, so peeking at them does not
help.

Left out because they cannot work in an unprivileged sandbox, or need real
hardware or the internet: Wi-Fi, real NIC settings with `ethtool` (it runs,
but veths have little to show), DHCP against a real network, WireGuard
(kernel module present, but key exchange with the outside world is out of
scope), and public DNS/TLS.

## Layout

```
exercises/      the files you edit, one directory per exercise
solutions/      one reference solution per exercise
.templates/     pristine copies, used by `netlings reset`
checks/         one check script per exercise; lib.sh holds the sandbox and helpers
*.go            the runner (Go standard library only), including the toy servers
scripts/        verify-all.sh: every solution passes, every exercise really is broken
```

## Adding an exercise

1. Create `exercises/NN_chapter/name/` with the files and a header comment
   (title, what it teaches, the task). It must fail its check as shipped.
2. Put the fixed version in `solutions/NN_chapter/name/` and copy the
   exercise to `.templates/NN_chapter/name/`.
3. Write `checks/NN_chapter/name.sh`: a `# REQUIRES:` line naming the tools
   it needs, a `# HINT` block of `#` lines, then
   `source "$NETLINGS_ROOT/checks/lib.sh"`. Call `sandbox` to get a fresh
   network, build the starting topology (`topo_pair`, `topo_router`,
   `topo_lan`, ...), call `sandbox_here` (that is where `netlings sandbox`
   stops), then run the learner's file (`run_setup`, `capture`,
   `load_ruleset`) and assert with `expect_*`. For answer files use
   `expect_answer KEY HASH` with `printf %s value | sha256sum`.
4. Run `scripts/verify-all.sh`.

Ordering is by chapter, then natural sort of the name.

## Other ways to learn

- [Julia Evans' zines](https://wizardzines.com/): *Networking! ACK!*, *Bite Size Networking*, *How DNS Works*, *HTTP: Learn your browser's language*
- [iximiuz Labs](https://labs.iximiuz.com/) and Ivan Velichko's posts, especially [How to set up a network namespace from scratch](https://iximiuz.com/en/posts/container-networking-is-simple/)
- [Linux network namespaces](https://man7.org/linux/man-pages/man7/network_namespaces.7.html), `man ip-netns`, `man ip-route`, `man nft`, `man tc-netem`
- [The nftables wiki](https://wiki.nftables.org/)
- [Beej's Guide to Network Programming](https://beej.us/guide/bgnet/), for the socket API underneath all this
- [High Performance Browser Networking](https://hpbn.co/) (free online), for TCP, TLS and HTTP in depth
