// client1 — go-redis basics: redis.Nil and expirations
package main

import (
	"cmp"
	"context"
	"errors"
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
		switch {
		case errors.Is(err, redis.Nil):
			fmt.Printf("%s is not cached\n", key)
		case err != nil:
			log.Fatal(err)
		default:
			fmt.Printf("%s = %s\n", key, val)
		}
	}

	if err := rdb.Set(ctx, "client1:last-run", time.Now().Format(time.RFC3339), time.Minute).Err(); err != nil {
		log.Fatal(err)
	}
}
