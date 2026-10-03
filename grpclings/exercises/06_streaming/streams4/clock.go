// streams4: cancellation and stream lifetime
//
// A stream lives until the handler returns, the client cancels its context,
// or the deadline passes. When the client goes away, stream.Context() is
// cancelled and Send starts returning errors. A handler that ignores both
// keeps running forever: a goroutine (and whatever it holds) leaked per
// abandoned stream, until the server falls over.
//
// Task: make Watch stop promptly when the client cancels. Wait for the next
// tick OR for stream.Context().Done(), whichever comes first, and stop on a
// failed Send as well.
package streams4

import (
	"time"

	"google.golang.org/grpc"
)

// Clock ticks every Interval.
type Clock struct {
	UnimplementedClockServiceServer
	Interval time.Duration
}

func (c *Clock) Watch(_ *WatchRequest, stream grpc.ServerStreamingServer[Tick]) error {
	var n int64
	for {
		time.Sleep(c.Interval)
		n++
		stream.Send(&Tick{N: n})
	}
}
