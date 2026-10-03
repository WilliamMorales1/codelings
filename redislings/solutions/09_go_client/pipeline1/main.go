// pipeline1 — pipelining
package main

import (
	"cmp"
	"context"
	"fmt"
	"log"
	"os"

	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: cmp.Or(os.Getenv("REDIS_ADDR"), "localhost:6390")})
	defer rdb.Close()

	_, err := rdb.Pipelined(ctx, func(pipe redis.Pipeliner) error {
		for i := range 2000 {
			pipe.Incr(ctx, fmt.Sprintf("views:page:%d", i%10))
		}
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("imported 2000 views")
}
