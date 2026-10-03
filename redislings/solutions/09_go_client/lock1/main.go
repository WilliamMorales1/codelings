// lock1 — a distributed lock: SET NX PX + a Lua release
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

// release deletes the lock only while it still holds our token.
var release = redis.NewScript(`
if redis.call('GET', KEYS[1]) == ARGV[1] then
  return redis.call('DEL', KEYS[1])
end
return 0
`)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: cmp.Or(os.Getenv("REDIS_ADDR"), "localhost:6390")})
	defer rdb.Close()

	work, err := strconv.Atoi(os.Args[1])
	if err != nil {
		log.Fatal("usage: lock1 WORK_MS")
	}

	token := rand.Text()
	ok, err := rdb.SetNX(ctx, lockKey, token, lockTTL).Result()
	if err != nil {
		log.Fatal(err)
	}
	if !ok {
		fmt.Println("busy")
		return
	}
	fmt.Println("acquired")

	time.Sleep(time.Duration(work) * time.Millisecond)

	n, err := release.Run(ctx, rdb, []string{lockKey}, token).Int()
	if err != nil {
		log.Fatal(err)
	}
	if n == 1 {
		fmt.Println("released")
	} else {
		fmt.Println("lost")
	}
}
