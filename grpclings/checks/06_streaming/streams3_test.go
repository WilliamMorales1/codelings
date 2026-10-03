//go:build check

package streams3

import (
	"errors"
	"io"
	"testing"
	"time"

	"google.golang.org/grpc"
	"grpclings/internal/check"
)

type member struct {
	t      *testing.T
	name   string
	stream grpc.BidiStreamingClient[ChatMessage, ChatMessage]
	in     chan *ChatMessage
	done   chan error
}

func connect(t *testing.T, c ChatServiceClient, name string) *member {
	stream, err := c.Chat(t.Context())
	if err != nil {
		t.Fatal(err)
	}
	m := &member{t: t, name: name, stream: stream, in: make(chan *ChatMessage, 64), done: make(chan error, 1)}
	go func() {
		for {
			msg, err := stream.Recv()
			if err != nil {
				m.done <- err
				return
			}
			m.in <- msg
		}
	}()
	return m
}

func (m *member) say(text string) {
	if err := m.stream.Send(&ChatMessage{User: m.name, Text: text}); err != nil {
		m.t.Fatalf("%s: Send: %v", m.name, err)
	}
}

// expect waits for a message with the given user and text, skipping others.
func (m *member) expect(user, text string) {
	m.t.Helper()
	timeout := time.After(2 * time.Second)
	for {
		select {
		case msg := <-m.in:
			if msg.GetUser() == user && msg.GetText() == text {
				return
			}
		case err := <-m.done:
			m.t.Fatalf("%s's stream ended (%v) while waiting for %s: %q", m.name, err, user, text)
		case <-timeout:
			m.t.Fatalf("%s never received %s: %q", m.name, user, text)
		}
	}
}

func TestRoom(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterChatServiceServer(s, NewRoom()) })
	c := NewChatServiceClient(conn)

	alice := connect(t, c, "alice")
	alice.say("joined")
	alice.expect("alice", "joined")
	bob := connect(t, c, "bob")
	bob.say("joined")
	bob.expect("bob", "joined")

	alice.say("hi bob")
	bob.expect("alice", "hi bob")
	bob.say("hi alice")
	alice.expect("bob", "hi alice")

	if err := bob.stream.CloseSend(); err != nil {
		t.Fatal(err)
	}
	select {
	case err := <-bob.done:
		if !errors.Is(err, io.EOF) {
			t.Errorf("after CloseSend, bob's stream should end cleanly (io.EOF), got %v", err)
		}
	case <-time.After(2 * time.Second):
		t.Error("the server did not end bob's stream after bob called CloseSend")
	}
	alice.say("still here")
	alice.expect("alice", "still here")
}
