//go:build check

package unary2

import (
	"fmt"
	"sync"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"
	"grpclings/internal/check"
)

func TestInventory(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterInventoryServiceServer(s, NewServer()) })
	c := NewInventoryServiceClient(conn)
	ctx := t.Context()

	tea := &Item{Sku: "tea", Name: "Green tea", Quantity: 12}
	res, err := c.AddItem(ctx, &AddItemRequest{Item: tea})
	if err != nil {
		t.Fatalf("AddItem: %v", err)
	}
	if !proto.Equal(res.GetItem(), tea) {
		t.Errorf("AddItem returned %v, want %v", res.GetItem(), tea)
	}
	got, err := c.GetItem(ctx, &GetItemRequest{Sku: "tea"})
	if err != nil || !proto.Equal(got.GetItem(), tea) {
		t.Fatalf("GetItem after AddItem = %v, %v", got.GetItem(), err)
	}

	var wg sync.WaitGroup
	for i := range 50 {
		wg.Go(func() {
			_, err := c.AddItem(ctx, &AddItemRequest{Item: &Item{Sku: fmt.Sprint("sku-", i), Quantity: int32(i)}})
			if err != nil {
				t.Errorf("concurrent AddItem: %v", err)
			}
		})
	}
	wg.Wait()
	got, _ = c.GetItem(ctx, &GetItemRequest{Sku: "sku-49"})
	if got.GetItem().GetQuantity() != 49 {
		t.Errorf("after 50 concurrent AddItems, sku-49 = %v", got.GetItem())
	}

	if _, err := c.AddItem(ctx, &AddItemRequest{Item: &Item{Sku: "tea", Quantity: 1}}); err != nil {
		t.Fatal(err)
	}
	got, _ = c.GetItem(ctx, &GetItemRequest{Sku: "tea"})
	if got.GetItem().GetQuantity() != 1 {
		t.Errorf("AddItem should replace an item with the same SKU, got %v", got.GetItem())
	}
}
