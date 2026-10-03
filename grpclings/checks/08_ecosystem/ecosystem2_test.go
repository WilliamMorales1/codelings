//go:build check

package ecosystem2

import (
	"slices"
	"testing"

	refpb "google.golang.org/grpc/reflection/grpc_reflection_v1"
	"google.golang.org/grpc/test/bufconn"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/descriptorpb"
	"grpclings/internal/check"
)

func TestReflection(t *testing.T) {
	lis := bufconn.Listen(1 << 20)
	s := NewServer()
	go s.Serve(lis)
	t.Cleanup(s.Stop)
	stream, err := refpb.NewServerReflectionClient(check.Dial(t, lis)).ServerReflectionInfo(t.Context())
	if err != nil {
		t.Fatal(err)
	}

	stream.Send(&refpb.ServerReflectionRequest{MessageRequest: &refpb.ServerReflectionRequest_ListServices{}})
	res, err := stream.Recv()
	if err != nil {
		t.Fatalf("reflection is not available: %v", err)
	}
	var names []string
	for _, svc := range res.GetListServicesResponse().GetService() {
		names = append(names, svc.GetName())
	}
	if !slices.Contains(names, "shop.v1.ShopService") {
		t.Errorf("ListServices = %v, want shop.v1.ShopService in it", names)
	}

	stream.Send(&refpb.ServerReflectionRequest{MessageRequest: &refpb.ServerReflectionRequest_FileContainingSymbol{FileContainingSymbol: "shop.v1.Product"}})
	res, err = stream.Recv()
	if err != nil {
		t.Fatal(err)
	}
	files := res.GetFileDescriptorResponse().GetFileDescriptorProto()
	if len(files) == 0 {
		t.Fatal("no descriptor for shop.v1.Product")
	}
	var fd descriptorpb.FileDescriptorProto
	if err := proto.Unmarshal(files[0], &fd); err != nil || fd.GetPackage() != "shop.v1" {
		t.Errorf("descriptor for shop.v1.Product: package %q, %v", fd.GetPackage(), err)
	}
}
