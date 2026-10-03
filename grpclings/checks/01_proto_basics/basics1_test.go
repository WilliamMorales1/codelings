//go:build check

package basics1

import (
	"testing"

	"google.golang.org/protobuf/reflect/protoreflect"
	"grpclings/internal/check"
)

func TestBook(t *testing.T) {
	md := check.Message(t, "library.v1.Book")
	check.Scalar(t, md, "title", 1, protoreflect.StringKind, protoreflect.Optional)
	check.Scalar(t, md, "author", 2, protoreflect.StringKind, protoreflect.Optional)
	check.Scalar(t, md, "page_count", 3, protoreflect.Int32Kind, protoreflect.Optional)
	check.Scalar(t, md, "isbn", 4, protoreflect.StringKind, protoreflect.Optional)
	if n := md.Fields().Len(); n != 4 {
		t.Errorf("Book has %d fields, want exactly 4", n)
	}
}
