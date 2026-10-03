// streams3: bidirectional streaming
//
// In `rpc Chat(stream ChatMessage) returns (stream ChatMessage)` reading and
// writing are independent: a client may send three messages and receive
// none, or the reverse. So a handler usually runs two loops: one goroutine
// Recv()s, the handler's own goroutine Send()s. Rules worth knowing:
//   - Recv returns io.EOF when the client calls CloseSend: end the handler.
//   - Send must not be called from two goroutines at once on one stream.
//   - Returning from the handler ends the stream for the client.
//
// Room keeps one outbox channel per connected stream; broadcast puts a
// message in every outbox (including the sender's, which doubles as an
// acknowledgement).
//
// Task: the current Chat just echoes each message back to its sender, so
// nobody ever hears anybody else. Make it a real room: every message a
// member sends reaches every member.
package streams3

import (
	"errors"
	"io"
	"sync"

	"google.golang.org/grpc"
)

// Room is a chat room shared by every connected stream.
type Room struct {
	UnimplementedChatServiceServer

	mu      sync.Mutex
	members map[chan *ChatMessage]struct{}
}

func NewRoom() *Room {
	return &Room{members: map[chan *ChatMessage]struct{}{}}
}

func (r *Room) join() chan *ChatMessage {
	ch := make(chan *ChatMessage, 64)
	r.mu.Lock()
	defer r.mu.Unlock()
	r.members[ch] = struct{}{}
	return ch
}

func (r *Room) leave(ch chan *ChatMessage) {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.members, ch)
}

func (r *Room) broadcast(m *ChatMessage) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for ch := range r.members {
		select {
		case ch <- m:
		default: // a member too slow to keep up misses messages rather than stalling the room
		}
	}
}

func (r *Room) Chat(stream grpc.BidiStreamingServer[ChatMessage, ChatMessage]) error {
	outbox := r.join()
	defer r.leave(outbox)

	recvErr := make(chan error, 1)
	go func() {
		for {
			m, err := stream.Recv()
			if errors.Is(err, io.EOF) {
				recvErr <- nil
				return
			}
			if err != nil {
				recvErr <- err
				return
			}
			r.broadcast(m)
		}
	}()

	for {
		select {
		case m := <-outbox:
			if err := stream.Send(m); err != nil {
				return err
			}
		case err := <-recvErr:
			return err
		}
	}
}
