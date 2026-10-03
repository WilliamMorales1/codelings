// worker1 — a stream worker with a consumer group
package main

import (
	"cmp"
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: cmp.Or(os.Getenv("REDIS_ADDR"), "localhost:6390")})
	defer rdb.Close()

	err := rdb.XGroupCreateMkStream(ctx, "payments", "billing", "0").Err()
	if err != nil && !strings.HasPrefix(err.Error(), "BUSYGROUP") {
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
			if err := rdb.XAck(ctx, "payments", "billing", msg.ID).Err(); err != nil {
				log.Fatal(err)
			}
		}
	}
	fmt.Printf("processed=%d total=%d\n", processed, total)
}
