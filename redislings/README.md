# redislings

Small exercises to get you used to **Redis** (and **Valkey**, its open-source
fork): the data types, expiry, transactions and Lua, pub/sub and streams,
data modelling, running a server, and finally talking to it from Go.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a small directory. You fix the files and save; once the
check passes the exercise is done and the runner moves you to the next one.

Each check starts its own throwaway server on a free port (`--save ''
--appendonly no`, a temporary `--dir`), seeds some data, runs your work
against it, looks at what happened, and kills the server. Nothing touches a
Redis you might already be running.

## Setup

You need a server and its CLI, plus Go to build the runner:

```sh
sudo pacman -S valkey go                 # Arch
sudo apt install redis-server golang     # Debian/Ubuntu
sudo dnf install valkey golang           # Fedora
brew install valkey go                   # macOS
```

If your package manager's Go is older than 1.27, get it from [go.dev/dl](https://go.dev/dl/).
Valkey or Redis both work: the runner uses whichever of `valkey-server` +
`valkey-cli` or `redis-server` + `redis-cli` it finds (Valkey first). You don't need to enable or start any
service; checks start their own servers.

Then build the runner:

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/redislings
go build -o redislings .
./redislings doctor
```

The runner uses only the Go standard library. Chapter `09_go_client` builds
your programs against [go-redis](https://github.com/redis/go-redis) v9, which
`go` downloads into its module cache on the first check (the only step that
needs the network); after that everything runs offline.

## Usage

```sh
./redislings watch          # the main loop: re-checks every time you save
./redislings                # check once, stop at the first unsolved exercise
./redislings list           # every exercise and its status
./redislings run lists3     # check one exercise by name
./redislings hint lists3    # print its hint
./redislings solution lists3
./redislings reset lists3   # back to the original, unsolved files
./redislings watch 05       # only chapter 05_transactions_lua
./redislings server         # a scratch server on port 6390 to play with
./redislings doctor         # which tools are missing
```

Open a second terminal with `./redislings watch` running, edit the file it
points at, and save. That is the whole workflow.

Most exercises are a `commands.redis` file: one command per line, exactly as
you'd type them into `redis-cli`. The runner strips `#` comment lines (redis-cli
has no comment syntax) and pipes the rest into `redis-cli --no-raw`, so a
command that returns an error fails the check. To try things by hand:

```sh
./redislings server                   # terminal 1
redis-cli -p 6390                     # terminal 2 (or valkey-cli)
grep -v '^#' exercises/01_strings/strings3/commands.redis | redis-cli -p 6390
```

Shell-script exercises (`fetch.sh`, `worker.sh`, ...) call `$REDIS_CLI`, which
defaults to `redis-cli -p 6390`, so they run against `redislings server` as
they are. Go exercises read `REDIS_ADDR` (default `localhost:6390`).

The `File:` line is a terminal hyperlink (OSC 8): click or ctrl-click it in
kitty, foot, WezTerm, Ghostty, recent VTE or iTerm2. Set `NO_COLOR=1` for
plain output.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, `commands.redis` files |
| `01_strings` | `SET`/`GET` and quoting, `INCR`/`INCRBY`, `SET NX`, `SET ... GET`, `MSET`/`MGET`, key naming |
| `02_expiry` | `EXPIRE`/`TTL`, `SET EX` versus a later `SET`, `KEEPTTL`/`PERSIST`, `GETEX` sliding sessions, the cache-aside pattern |
| `03_hashes_lists` | `HSET`, `HINCRBY`/`HDEL`, `LPUSH` vs `RPUSH`, capped lists with `LTRIM`, reliable queues with `LMOVE`, a `BLPOP` worker |
| `04_sets_zsets` | `SADD`, `SINTER`/`SUNIONSTORE`, a leaderboard with `ZINCRBY`/`ZADD GT`, top N, score ranges with exclusive bounds, a sliding-window rate limiter |
| `05_transactions_lua` | `MULTI`/`EXEC`, `WATCH` optimistic locking, `EVAL` scripts, `KEYS`/`ARGV`, `FUNCTION LOAD` / `FCALL_RO` |
| `06_pubsub_streams` | `PUBLISH`, `SUBSCRIBE` vs `PSUBSCRIBE`, `XADD`, `XREVRANGE`, `MAXLEN` vs `MAXLEN ~`, consumer groups, `XAUTOCLAIM` |
| `07_data_modeling` | secondary indexes with sets and sorted sets, bitmaps, HyperLogLog, geo |
| `08_ops` | `SCAN` instead of `KEYS`, deleting by pattern with `UNLINK`, parsing `INFO`, eviction policies, RDB vs AOF, ACL users |
| `09_go_client` | go-redis: `redis.Nil` and TTLs, pipelines, a pub/sub consumer, a stream worker, a distributed lock with a Lua release |

51 exercises. Everything in chapters 00 to 08 works the same on Redis 7+ and
Valkey 8+; the checks were verified against Valkey 9.1.

## Layout

```
exercises/      what you edit, one directory per exercise
solutions/      one reference solution per exercise
.templates/     pristine copies, used by `redislings reset`
checks/         one bash check per exercise (the spec); lib.sh has the shared helpers,
                09_go_client/gomod/ the go.mod the Go exercises are built with
*.go            the runner (standard library only)
scripts/        verify-all.sh: every solution passes, every untouched exercise fails
```

## Adding an exercise

1. Create `exercises/<chapter>/<name>/` with the file(s) to edit. Open with a
   comment block (title, what to learn, the task), and must fail its
   check as shipped.
2. Put the fixed version in `solutions/<chapter>/<name>/` and copy the
   exercise directory to `.templates/<chapter>/<name>/`.
3. Write `checks/<chapter>/<name>.sh`: a `# REQUIRES: redis` line (plus `go`
   or anything else it needs), then a `# HINT` block of `#` lines, then
   `source "$REDISLINGS_ROOT/checks/lib.sh"`. It runs with the exercise as
   its working directory and passes by exiting 0. The helpers do the
   plumbing: `start_redis`, `seed`, `run_file`, `r`, `expect_eq`,
   `expect_between`, `listen`, `go_build`, ...
4. Run `scripts/verify-all.sh` (add `-v` to see why each untouched exercise
   fails, and a chapter prefix to limit it).

Ordering is by chapter directory, then by exercise name with numbers sorted
naturally (`lists2` before `lists10`). Names must be unique across the course.

## Other ways to learn Redis

- [redis.io/learn](https://redis.io/learn) — tutorials and how-tos from Redis
- [Redis University](https://university.redis.io/) — free courses, from data structures to streams
- [The command reference](https://redis.io/docs/latest/commands/) and [valkey.io/commands](https://valkey.io/commands/) — every command, with complexity and examples
- *Redis in Action* by Josiah Carlson — patterns for real applications (older, still sound)
