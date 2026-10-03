// client1 — go-redis basics: redis.Nil and expirations
//
// Learn: github.com/redis/go-redis/v9 talks to Redis and Valkey alike.
// Every command returns a *Cmd; .Result() gives the value and an error.
// A missing key is reported as the sentinel error redis.Nil, which is
// not a failure: check it with errors.Is(err, redis.Nil). In Set, the
// last argument is the expiration, and 0 means "keep forever".
//
// Task: `go run . KEY...` prints "KEY = VALUE" for each key, or
// "KEY is not cached" when it doesn't exist, then records the run in
// client1:last-run with a TTL of one minute. Right now the first missing
// key crashes the program, and last-run never expires.
//
// Try it: redislings server, then from this directory:
//
//	REDIS_ADDR=localhost:6390 go run . greeting nope
//
package main

import (
	"cmp"
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: cmp.Or(os.Getenv("REDIS_ADDR"), "localhost:6390")})
	defer rdb.Close()

	for _, key := range os.Args[1:] {
		val, err := rdb.Get(ctx, key).Result()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("%s = %s\n", key, val)
	}

	if err := rdb.Set(ctx, "client1:last-run", time.Now().Format(time.RFC3339), 0).Err(); err != nil {
		log.Fatal(err)
	}
}
