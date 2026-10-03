// wire1: reading the wire format by hand
//
// A protobuf message on the wire is just a sequence of (tag, value) records.
//
//	tag     = varint of (field_number << 3) | wire_type
//	wire types: 0 VARINT, 1 I64 (8 bytes, little endian), 2 LEN (varint
//	            length, then that many bytes), 5 I32 (4 bytes, little endian)
//	varint  = 7 bits per byte, least significant group FIRST; the top bit of
//	          each byte says "more bytes follow".
//	sint32/sint64 use zigzag on top of varint: 0->0, -1->1, 1->2, -2->3, 2->4...
//
// Decode each byte string below BY HAND (pencil, or `printf` in a shell) and
// fill in the answers. Getting there is the point; the check only compares.
// Afterwards, try it on real data: `protoscope` or `protoc --decode_raw`
// (e.g. `printf '\x08\x96\x01' | protoc --decode_raw`).
package wire1

// Q1: 08 96 01
var (
	Q1Field    = 0
	Q1WireType = 0
	Q1Value    = 0
)

// Q2: 12 07 74 65 73 74 69 6e 67
var (
	Q2Field    = 0
	Q2WireType = 0
	Q2Length   = 0
	Q2Text     = ""
)

// Q3: 18 03   (the schema says: sint32 delta = 3;)
var Q3Value = 0

// Q4: 20 ff ff ff ff ff ff ff ff ff 01   (the schema says: int32 offset = 4;)
// How many bytes does this one field take, and what is the value?
var (
	Q4TotalBytes = 0
	Q4Value      = 0
)

// Q5: 2a 03 01 02 03   (the schema says: repeated int32 ids = 5;)
// Repeated scalars are "packed" into one LEN record by default in proto3.
var Q5Values = []int{}

// Q6: 0a 03 61 62 63 10 2a 1d 00 00 80 3f
// No schema this time. List the field numbers, in order, and the wire type of
// the last field. Then: the last field is a `float`; what is its value?
var (
	Q6Fields       = []int{}
	Q6LastWireType = 0
	Q6LastFloat    = 0.0
)
