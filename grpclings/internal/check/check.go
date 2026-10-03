// Package check holds helpers shared by the hidden tests in checks/.
package check

import (
	"context"
	"net"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/test/bufconn"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
)

// Message looks up a message by its full proto name, e.g. "library.v1.Book".
func Message(t testing.TB, name string) protoreflect.MessageDescriptor {
	t.Helper()
	d, err := protoregistry.GlobalFiles.FindDescriptorByName(protoreflect.FullName(name))
	if err != nil {
		t.Fatalf("no message named %s in your .proto (check the package and the message name)", name)
	}
	md, ok := d.(protoreflect.MessageDescriptor)
	if !ok {
		t.Fatalf("%s exists but is not a message", name)
	}
	return md
}

// Enum looks up an enum by its full proto name.
func Enum(t testing.TB, name string) protoreflect.EnumDescriptor {
	t.Helper()
	d, err := protoregistry.GlobalFiles.FindDescriptorByName(protoreflect.FullName(name))
	if err != nil {
		t.Fatalf("no enum named %s in your .proto", name)
	}
	ed, ok := d.(protoreflect.EnumDescriptor)
	if !ok {
		t.Fatalf("%s exists but is not an enum", name)
	}
	return ed
}

// Field returns a field of md by name, failing the test if it is missing.
func Field(t testing.TB, md protoreflect.MessageDescriptor, name string) protoreflect.FieldDescriptor {
	t.Helper()
	fd := md.Fields().ByName(protoreflect.Name(name))
	if fd == nil {
		t.Fatalf("%s has no field %q", md.FullName(), name)
	}
	return fd
}

// Scalar asserts a field's number, kind and cardinality.
func Scalar(t testing.TB, md protoreflect.MessageDescriptor, name string, number int, kind protoreflect.Kind, card protoreflect.Cardinality) protoreflect.FieldDescriptor {
	t.Helper()
	fd := Field(t, md, name)
	if int(fd.Number()) != number {
		t.Errorf("%s: field number is %d, want %d", fd.FullName(), fd.Number(), number)
	}
	if fd.Kind() != kind {
		t.Errorf("%s: type is %s, want %s", fd.FullName(), fd.Kind(), kind)
	}
	if fd.Cardinality() != card {
		t.Errorf("%s: cardinality is %s, want %s", fd.FullName(), fd.Cardinality(), card)
	}
	return fd
}

// MessageField asserts a field holds the message type msg (full name).
func MessageField(t testing.TB, md protoreflect.MessageDescriptor, name string, number int, msg string, card protoreflect.Cardinality) protoreflect.FieldDescriptor {
	t.Helper()
	fd := Scalar(t, md, name, number, protoreflect.MessageKind, card)
	if fd.Kind() == protoreflect.MessageKind && string(fd.Message().FullName()) != msg {
		t.Errorf("%s: holds %s, want %s", fd.FullName(), fd.Message().FullName(), msg)
	}
	return fd
}

// Serve starts a gRPC server on an in-memory bufconn listener and returns a client connection to it.
func Serve(t testing.TB, register func(*grpc.Server), opts ...grpc.ServerOption) *grpc.ClientConn {
	t.Helper()
	return Dial(t, Listen(t, register, opts...))
}

// Listen starts a gRPC server on an in-memory bufconn listener, stopped when the test ends.
func Listen(t testing.TB, register func(*grpc.Server), opts ...grpc.ServerOption) *bufconn.Listener {
	t.Helper()
	lis := bufconn.Listen(1 << 20)
	srv := grpc.NewServer(opts...)
	register(srv)
	go srv.Serve(lis)
	t.Cleanup(srv.Stop)
	return lis
}

// Dial connects to a bufconn listener; extra options are appended to the defaults.
func Dial(t testing.TB, lis *bufconn.Listener, opts ...grpc.DialOption) *grpc.ClientConn {
	t.Helper()
	opts = append([]grpc.DialOption{
		grpc.WithContextDialer(func(ctx context.Context, _ string) (net.Conn, error) { return lis.DialContext(ctx) }),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	}, opts...)
	conn, err := grpc.NewClient("passthrough:///bufnet", opts...)
	if err != nil {
		t.Fatalf("grpc.NewClient: %v", err)
	}
	t.Cleanup(func() { conn.Close() })
	return conn
}
