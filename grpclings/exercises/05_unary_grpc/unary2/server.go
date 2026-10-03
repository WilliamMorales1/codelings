// unary2: implementing a server
//
// inventory.proto declares InventoryService. The generated
// InventoryServiceServer interface lists one Go method per RPC, plus an
// unexported mustEmbedUnimplementedInventoryServiceServer method: the only
// way to satisfy it is to embed UnimplementedInventoryServiceServer (by
// value) in your struct. That is deliberate; it means adding an RPC to the
// .proto later does not break every server that has not implemented it yet.
//
// gRPC calls handlers concurrently, one goroutine per RPC, so shared state
// needs a lock.
//
// Task: make Server register with a grpc.Server, and implement AddItem so
// that it stores the item (replacing one with the same SKU) and returns it.
// GetItem is done; it shows the shape.
package unary2

import (
	"context"
	"sync"

	"google.golang.org/protobuf/proto"
)

// Server is an in-memory inventory.
type Server struct {
	mu    sync.Mutex
	items map[string]*Item
}

// NewServer returns an empty inventory.
func NewServer() *Server {
	return &Server{items: map[string]*Item{}}
}

func (s *Server) GetItem(_ context.Context, req *GetItemRequest) (*GetItemResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	// Clone: handing out our stored pointer would let callers mutate the store.
	return &GetItemResponse{Item: proto.CloneOf(s.items[req.GetSku()])}, nil
}

func (s *Server) AddItem(_ context.Context, req *AddItemRequest) (*AddItemResponse, error) {
	// TODO
	return nil, nil
}
