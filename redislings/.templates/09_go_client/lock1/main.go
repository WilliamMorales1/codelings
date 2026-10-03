// lock1 — a distributed lock: SET NX PX + a Lua release
//
// Learn: the simplest Redis lock is SET key <random token> NX PX <ttl>.
// NX makes only one client win; the TTL frees the lock if the holder
// crashes; the random token identifies the holder. Releasing must check
// the token and delete in ONE atomic step (a Lua script, as in lua2): if
// our work outlived the TTL, the lock may now belong to someone else,
// and a plain DEL would free THEIR lock.
//
// Task: `go run . WORK_MS` takes lock:nightly-report for 300 ms, pretends
// to work for WORK_MS, and releases it. It prints "busy" if the lock is
// taken, otherwise "acquired" and then "released", or "lost" when the
// lock had expired and was no longer ours. Right now the lock never
// expires, and the release deletes whatever is there.
//
package main

import (
	"cmp"
	"context"
	"crypto/rand"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"
)

const (
	lockKey = "lock:nightly-report"
	lockTTL = 300 * time.Millisecond
)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: cmp.Or(os.Getenv("REDIS_ADDR"), "localhost:6390")})
	defer rdb.Close()

	work, err := strconv.Atoi(os.Args[1])
	if err != nil {
		log.Fatal("usage: lock1 WORK_MS")
	}

	token := rand.Text()
	ok, err := rdb.SetNX(ctx, lockKey, token, 0).Result()
	if err != nil {
		log.Fatal(err)
	}
	if !ok {
		fmt.Println("busy")
		return
	}
	fmt.Println("acquired")

	time.Sleep(time.Duration(work) * time.Millisecond)

	if err := rdb.Del(ctx, lockKey).Err(); err != nil {
		log.Fatal(err)
	}
	fmt.Println("released")
}
