// subscriber1 — a pub/sub consumer in Go
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
	if _, err := sub.Receive(ctx); err != nil {
		log.Fatal(err)
	}
	if err := sub.Subscribe(ctx, "control"); err != nil {
		log.Fatal(err)
	}
	if _, err := sub.Receive(ctx); err != nil {
		log.Fatal(err)
	}
	fmt.Println("ready")

	counts := map[string]int{}
	for msg := range sub.Channel() {
		if msg.Channel == "control" {
			break
		}
		region := strings.TrimPrefix(msg.Channel, "orders:")
		counts[region]++
	}
	for _, region := range slices.Sorted(maps.Keys(counts)) {
		fmt.Println(region, counts[region])
	}
}
