//go:build check

package ecosystem3

import (
	"encoding/json"
	"net"
	"os"
	"os/exec"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func TestCallScript(t *testing.T) {
	lis, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	s := grpc.NewServer()
	RegisterShopServiceServer(s, Shop{})
	reflection.Register(s)
	go s.Serve(lis)
	defer s.Stop()

	cmd := exec.CommandContext(t.Context(), "bash", "call.sh")
	cmd.Env = append(os.Environ(), "ADDR="+lis.Addr().String())
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("call.sh failed: %v\n%s", err, out)
	}
	var res struct {
		Product struct {
			Sku, Name string
		}
	}
	if err := json.Unmarshal(out, &res); err != nil {
		t.Fatalf("call.sh did not print JSON: %v\n%s", err, out)
	}
	if res.Product.Sku != "mug" || res.Product.Name != "Blue mug" {
		t.Errorf("call.sh printed %s, want the mug", out)
	}
}
