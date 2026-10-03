// worker1 — a stream worker with a consumer group
//
// Learn: a real worker (1) creates its group if needed. XGROUP CREATE
// fails with a BUSYGROUP error when the group exists, which on every run
// but the first is expected; (2) reads with XREADGROUP ... > and a Block
// timeout, getting redis.Nil when nothing arrived; (3) XACKs each entry
// after handling it, or the entry stays pending forever and a restart
// (reading from 0 instead of >) would process it again.
//
// Task: sum the "amount" field of the payments stream, as consumer
// "worker-1" of group "billing", until no new entry arrives for 500 ms,
// then print "processed=N total=SUM". The check runs the worker twice
// with new payments in between: the second run must work too, and
// nothing may stay pending.
//
package main

import (
	"cmp"
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: cmp.Or(os.Getenv("REDIS_ADDR"), "localhost:6390")})
	defer rdb.Close()

	if err := rdb.XGroupCreateMkStream(ctx, "payments", "billing", "0").Err(); err != nil {
		log.Fatal(err)
	}

	processed, total := 0, 0
	for {
		streams, err := rdb.XReadGroup(ctx, &redis.XReadGroupArgs{
			Group:    "billing",
			Consumer: "worker-1",
			Streams:  []string{"payments", ">"},
			Count:    10,
			Block:    500 * time.Millisecond,
		}).Result()
		if errors.Is(err, redis.Nil) {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		for _, msg := range streams[0].Messages {
			amount, err := strconv.Atoi(fmt.Sprint(msg.Values["amount"]))
			if err != nil {
				log.Fatalf("entry %s: bad amount: %v", msg.ID, err)
			}
			total += amount
			processed++
		}
	}
	fmt.Printf("processed=%d total=%d\n", processed, total)
}
