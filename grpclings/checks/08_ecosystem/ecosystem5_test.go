//go:build check

package ecosystem5

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
)

func post(t *testing.T, url, body string) (int, map[string]any) {
	t.Helper()
	res, err := http.Post(url, "application/json", strings.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	b, _ := io.ReadAll(res.Body)
	var out map[string]any
	json.Unmarshal(b, &out)
	return res.StatusCode, out
}

func TestConnect(t *testing.T) {
	mux := http.NewServeMux()
	mux.Handle(NewHandler())
	srv := httptest.NewServer(mux)
	defer srv.Close()
	url := srv.URL + "/shop.v1.ShopService/GetProduct"

	code, body := post(t, url, `{"sku": "tea"}`)
	if code != http.StatusOK {
		t.Fatalf("POST %s: HTTP %d %v", url, code, body)
	}
	if p, _ := body["product"].(map[string]any); p["name"] != "Green tea" {
		t.Errorf("body = %v", body)
	}

	code, body = post(t, url, `{"sku": "caviar"}`)
	if code != http.StatusNotFound || body["code"] != "not_found" {
		t.Errorf("unknown SKU: HTTP %d %v, want 404 with code not_found", code, body)
	}

	// The same handler also serves typed Go clients.
	c := connect.NewClient[GetProductRequest, GetProductResponse](srv.Client(), url)
	res, err := c.CallUnary(t.Context(), connect.NewRequest(&GetProductRequest{Sku: "tea"}))
	if err != nil || res.Msg.GetProduct().GetPriceCents() != 450 {
		t.Errorf("connect client: %v, %v", res, err)
	}
}
