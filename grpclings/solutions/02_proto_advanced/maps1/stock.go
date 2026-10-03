package maps1

import (
	"maps"
	"slices"
)

// LowStock returns the SKUs whose stock is below threshold, sorted.
func LowStock(w *Warehouse, threshold int32) []string {
	var low []string
	for _, sku := range slices.Sorted(maps.Keys(w.GetStockBySku())) {
		if w.GetStockBySku()[sku] < threshold {
			low = append(low, sku)
		}
	}
	return low
}
