// streams1: server streaming
//
// `returns (stream LogLine)` lets the server send many responses to one
// request. The generated handler gets the request plus a stream:
//
//	func (s *Server) Tail(req *TailRequest, stream grpc.ServerStreamingServer[LogLine]) error
//
// Call stream.Send(line) as often as you like; returning from the handler
// ends the stream (return nil for success, or a status error).
//
// The client gets a stream too and calls Recv() until it returns io.EOF,
// which means "the server finished cleanly", not failure.
//
// Task:
//  1. implement Tail: send every stored line whose level matches (all lines
//     when req.level is empty), in order;
//  2. fix Collect, which currently reports every successful stream as an error.
package streams1

import (
	"context"

	"google.golang.org/grpc"
)

// Server serves a fixed log.
type Server struct {
	UnimplementedLogServiceServer
	Lines []*LogLine
}

func (s *Server) Tail(req *TailRequest, stream grpc.ServerStreamingServer[LogLine]) error {
	// TODO
	return nil
}

// Collect calls Tail and gathers every line the server sends.
func Collect(ctx context.Context, c LogServiceClient, level string) ([]*LogLine, error) {
	stream, err := c.Tail(ctx, &TailRequest{Level: level})
	if err != nil {
		return nil, err
	}
	var lines []*LogLine
	for {
		line, err := stream.Recv()
		if err != nil {
			return nil, err
		}
		lines = append(lines, line)
	}
}
