//go:build check

package intro1

import (
	"testing"

	"google.golang.org/protobuf/reflect/protoreflect"
	"grpclings/internal/check"
)

func TestGreeting(t *testing.T) {
	md := check.Message(t, "intro.v1.Greeting")
	check.Scalar(t, md, "text", 1, protoreflect.StringKind, protoreflect.Optional)
	if got := Greet("gopher").GetText(); got != "Hello, gopher!" {
		t.Fatalf(`Greet("gopher").Text = %q, want "Hello, gopher!"`, got)
	}
}
