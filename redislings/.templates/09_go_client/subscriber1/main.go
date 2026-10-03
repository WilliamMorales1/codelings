// subscriber1 — a pub/sub consumer in Go
//
// Learn: rdb.PSubscribe / rdb.Subscribe return a *redis.PubSub bound to
// its own connection. Receive() waits for the subscription to be
// confirmed; after that, Channel() delivers *redis.Message values. For a
// pattern subscription, msg.Pattern is the pattern that matched
// ("orders:*") and msg.Channel the actual channel ("orders:eu").
// One PubSub can hold several subscriptions: call Subscribe on it too.
//
// Task: count order messages per region (the part of the channel after
// "orders:") until a message arrives on the exact channel "control",
// then print one "region count" line per region, sorted by region.
// Right now every message is counted under the same region, and the
// program never hears about "control".
//
package main

import (
	"cmp"
	"context"
	"fmt"
	"log"
	"maps"
	"os"
	"slices"
	"strings"

	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: cmp.Or(os.Getenv("REDIS_ADDR"), "localhost:6390")})
	defer rdb.Close()

	sub := rdb.PSubscribe(ctx, "orders:*")
	defer sub.Close()
	// Wait for the server's confirmation, so nothing published after "ready" is missed.
	if _, err := sub.Receive(ctx); err != nil {
		log.Fatal(err)
	}
	fmt.Println("ready")

	counts := map[string]int{}
	for msg := range sub.Channel() {
		if msg.Channel == "control" {
			break
		}
		region := strings.TrimPrefix(msg.Pattern, "orders:")
		counts[region]++
	}
	for _, region := range slices.Sorted(maps.Keys(counts)) {
		fmt.Println(region, counts[region])
	}
}
