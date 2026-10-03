//go:build check

package maps1

import (
	"slices"
	"testing"

	"google.golang.org/protobuf/reflect/protoreflect"
	"grpclings/internal/check"
)

func TestMaps(t *testing.T) {
	md := check.Message(t, "inventory.v1.Warehouse")
	stock := check.Field(t, md, "stock_by_sku")
	if !stock.IsMap() || stock.MapKey().Kind() != protoreflect.StringKind || stock.MapValue().Kind() != protoreflect.Int32Kind {
		t.Errorf("stock_by_sku should be map<string, int32>")
	}
	shelves := check.Field(t, md, "shelves")
	if !shelves.IsMap() || shelves.MapKey().Kind() != protoreflect.StringKind ||
		shelves.MapValue().Kind() != protoreflect.MessageKind || shelves.MapValue().Message().FullName() != "inventory.v1.Shelf" {
		t.Errorf("shelves should be map<string, Shelf>")
	}

	w := &Warehouse{StockBySku: map[string]int32{"tea": 3, "mug": 40, "pot": 0, "cup": 9, "jar": 12, "lid": 1}}
	got := LowStock(w, 10)
	want := []string{"cup", "lid", "pot", "tea"}
	if !slices.Equal(got, want) {
		t.Errorf("LowStock(threshold 10) = %v, want %v", got, want)
	}
	if got := LowStock(&Warehouse{}, 10); len(got) != 0 {
		t.Errorf("LowStock of an empty warehouse = %v, want none", got)
	}
}
