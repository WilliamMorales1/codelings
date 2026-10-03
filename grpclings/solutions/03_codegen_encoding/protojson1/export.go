// protojson1: the canonical JSON mapping
//
// Protobuf defines its own JSON mapping, implemented by
// google.golang.org/protobuf/encoding/protojson (NOT encoding/json):
// Timestamps become RFC 3339 strings, enums become their names, int64 become
// strings, and field names become lowerCamelCase by default. Knobs live on
// protojson.MarshalOptions / UnmarshalOptions.
//
// Note: protojson output is deliberately unstable (it randomly adds spaces),
// so never compare it byte for byte or hash it.
//
// Task: a log pipeline downstream wants:
//   - the .proto field names (event_id, not eventId),
//   - every field present, even when zero (retry_count: 0),
//   - and our importer must not choke on fields added by newer producers.
package protojson1

import "google.golang.org/protobuf/encoding/protojson"

// Export renders ev for the log pipeline.
func Export(ev *Event) ([]byte, error) {
	return protojson.MarshalOptions{UseProtoNames: true, EmitUnpopulated: true}.Marshal(ev)
}

// Import parses JSON produced by any version of the producer.
func Import(b []byte) (*Event, error) {
	ev := &Event{}
	if err := (protojson.UnmarshalOptions{DiscardUnknown: true}).Unmarshal(b, ev); err != nil {
		return nil, err
	}
	return ev, nil
}
