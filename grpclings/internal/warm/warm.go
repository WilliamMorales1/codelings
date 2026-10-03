// Package warm imports every library the checks use, so one `go build` of it
// downloads and compiles them all before the first check runs.
package warm

import (
	_ "connectrpc.com/connect"
	_ "google.golang.org/genproto/googleapis/rpc/errdetails"
	_ "google.golang.org/grpc"
	_ "google.golang.org/grpc/codes"
	_ "google.golang.org/grpc/credentials/insecure"
	_ "google.golang.org/grpc/health"
	_ "google.golang.org/grpc/health/grpc_health_v1"
	_ "google.golang.org/grpc/metadata"
	_ "google.golang.org/grpc/reflection"
	_ "google.golang.org/grpc/reflection/grpc_reflection_v1"
	_ "google.golang.org/grpc/status"
	_ "google.golang.org/grpc/test/bufconn"
	_ "google.golang.org/protobuf/encoding/protojson"
	_ "google.golang.org/protobuf/encoding/protowire"
	_ "google.golang.org/protobuf/proto"
	_ "google.golang.org/protobuf/reflect/protoreflect"
	_ "google.golang.org/protobuf/types/known/durationpb"
	_ "google.golang.org/protobuf/types/known/emptypb"
	_ "google.golang.org/protobuf/types/known/fieldmaskpb"
	_ "google.golang.org/protobuf/types/known/timestamppb"
)
