//go:build check

package streams2

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"testing"

	"google.golang.org/grpc"
	"grpclings/internal/check"
)

func TestUpload(t *testing.T) {
	conn := check.Serve(t, func(s *grpc.Server) { RegisterFileServiceServer(s, Server{}) })
	c := NewFileServiceClient(conn)
	data := bytes.Repeat([]byte("protobuf "), 1000)
	sum := sha256.Sum256(data)
	res, err := Send(t.Context(), c, data, 1024)
	if err != nil {
		t.Fatalf("Upload: %v", err)
	}
	if res.GetSize() != int64(len(data)) || res.GetSha256() != hex.EncodeToString(sum[:]) {
		t.Errorf("summary = %v, want size %d sha256 %x", res, len(data), sum)
	}
	empty, err := Send(t.Context(), c, nil, 1024)
	if err != nil || empty.GetSize() != 0 {
		t.Errorf("empty upload: %v, %v", empty, err)
	}
}
