//go:build check

package basics2

import (
	"testing"

	"google.golang.org/protobuf/reflect/protoreflect"
	"grpclings/internal/check"
)

func TestReading(t *testing.T) {
	md := check.Message(t, "telemetry.v1.Reading")
	o := protoreflect.Optional
	check.Scalar(t, md, "device_id", 1, protoreflect.StringKind, o)
	check.Scalar(t, md, "sequence", 2, protoreflect.Uint64Kind, o)
	check.Scalar(t, md, "temperature_c", 3, protoreflect.DoubleKind, o)
	check.Scalar(t, md, "offset_ms", 4, protoreflect.Sint64Kind, o)
	check.Scalar(t, md, "checksum", 5, protoreflect.Fixed32Kind, o)
	check.Scalar(t, md, "frame", 6, protoreflect.BytesKind, o)
	check.Scalar(t, md, "healthy", 7, protoreflect.BoolKind, o)
}
