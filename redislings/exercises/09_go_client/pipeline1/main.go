// pipeline1 — pipelining
//
// Learn: each command is a network round trip: send, wait, read. On
// localhost that's tens of microseconds; across a data centre it's
// closer to a millisecond, so 10,000 commands take 10 seconds of mostly
// waiting. A pipeline sends many commands in one write and reads all the
// replies afterwards. In go-redis: rdb.Pipelined(ctx, func(pipe
// redis.Pipeliner) error { ... }) queues commands on pipe and sends
// them when the function returns. (A pipeline is not a transaction:
// TxPipelined wraps it in MULTI/EXEC.)
//
// Task: import the page views below, 2000 increments across 10 pages,
// using a pipeline instead of one round trip per increment. The check
// counts how many times the server had to read from the connection.
//
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

	for i := range 2000 {
		key := fmt.Sprintf("views:page:%d", i%10)
		if err := rdb.Incr(ctx, key).Err(); err != nil {
			log.Fatal(err)
		}
	}
	fmt.Println("imported 2000 views")
}
