// metrics6 -- observable gauges
//
// Some values are cheaper to *read* when asked than to track on every
// change: queue depth, cache size, memory in use. Asynchronous
// ("observable") instruments take a callback that the SDK runs on each
// collection; the callback observes the current value.
//
// The callback must read the value when it runs. A value captured when
// the instrument was registered is frozen forever.
//
// Task: queue.depth always reports the depth at startup. Make the callback
// observe the queue's current length.
//

package metrics6

import (
	"context"
	"sync"

	"go.opentelemetry.io/otel/metric"
)

type Queue struct {
	mu    sync.Mutex
	items []string
}

func (q *Queue) Push(s string) {
	q.mu.Lock()
	defer q.mu.Unlock()
	q.items = append(q.items, s)
}

func (q *Queue) Len() int {
	q.mu.Lock()
	defer q.mu.Unlock()
	return len(q.items)
}

// Register reports q's depth as the queue.depth gauge.
func Register(m metric.Meter, q *Queue) error {
	depth := int64(q.Len())
	_, err := m.Int64ObservableGauge("queue.depth",
		metric.WithUnit("{item}"),
		metric.WithInt64Callback(func(_ context.Context, o metric.Int64Observer) error {
			o.Observe(depth)
			return nil
		}),
	)
	return err
}
