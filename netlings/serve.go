package main

import (
	"bufio"
	"cmp"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/json/jsontext"
	"encoding/json/v2"
	"encoding/pem"
	"flag"
	"fmt"
	"io"
	"math/big"
	"net"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

const serveUsage = `netlings serve KIND [flags]

KIND is one of:
    http    -addr :80 [-name NAME] [-vhost host=text ...]
    https   -addr :443 [-name NAME] -hosts a.test,b.test [-ca-out ca.pem] [-vhost host=text ...]
    echo    -addr :7          TCP: every line you send comes straight back
    udp     -addr :5140 -out FILE   UDP: every datagram is appended to FILE
    dns     -addr :53 -zone FILE [-log FILE]   a tiny authoritative DNS server

The HTTP(S) server answers:
    GET  /                 "hello from NAME" (or the -vhost text for that Host header)
    GET  /whoami           JSON: your address as the server sees it, Host, headers
    GET  /api/status       needs "Accept: application/json" and "X-Token: netlings"
    POST /api/items        needs a JSON body {"name": "..."} sent as application/json
    GET  /old              301 -> /moved, 302 -> /final
    GET  /status/{code}    replies with that status code
    GET  /bytes?kb=N       N kilobytes of "x"

Run it inside a namespace, e.g.  ip netns exec b netlings serve http -addr :80 &`

func cmdServe(args []string) int {
	if len(args) == 0 || args[0] == "-h" || args[0] == "--help" {
		fmt.Println(serveUsage)
		return 2
	}
	kind, args := args[0], args[1:]
	fl := flag.NewFlagSet("serve "+kind, flag.ContinueOnError)
	addr := fl.String("addr", "", "listen address, host:port")
	name := fl.String("name", "", "name the server introduces itself with")
	hosts := fl.String("hosts", "localhost", "https: comma-separated DNS names (and IPs) for the certificate")
	caOut := fl.String("ca-out", "", "https: write the CA certificate (PEM) here")
	out := fl.String("out", "", "udp: file to append datagrams to")
	zone := fl.String("zone", "", "dns: zone file")
	logFile := fl.String("log", "", "dns: append one line per query here")
	vhosts := map[string]string{}
	fl.Func("vhost", "host=text: body of / for that Host header (repeatable)", func(s string) error {
		h, text, ok := strings.Cut(s, "=")
		if !ok {
			return fmt.Errorf("want host=text")
		}
		vhosts[strings.ToLower(h)] = text
		return nil
	})
	if err := fl.Parse(args); err != nil {
		return 2
	}
	if *name == "" {
		*name, _ = os.Hostname()
	}
	var err error
	switch kind {
	case "http":
		err = serveHTTP(cmp.Or(*addr, ":80"), httpHandler(*name, vhosts), nil)
	case "https":
		var cfg *tls.Config
		if cfg, err = selfSigned(strings.Split(*hosts, ","), *caOut); err == nil {
			err = serveHTTP(cmp.Or(*addr, ":443"), httpHandler(*name, vhosts), cfg)
		}
	case "echo":
		err = serveEcho(cmp.Or(*addr, ":7"))
	case "udp":
		if *out == "" {
			err = fmt.Errorf("udp needs -out FILE")
		} else {
			err = serveUDP(cmp.Or(*addr, ":5140"), *out)
		}
	case "dns":
		if *zone == "" {
			err = fmt.Errorf("dns needs -zone FILE")
		} else {
			err = serveDNS(cmp.Or(*addr, ":53"), *zone, *logFile)
		}
	default:
		fmt.Println(serveUsage)
		return 2
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "netlings serve:", err)
		return 1
	}
	return 0
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.MarshalWrite(w, v, jsontext.WithIndent("  "))
	w.Write([]byte("\n"))
}

func httpHandler(name string, vhosts map[string]string) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		host := r.Host
		if h, _, err := net.SplitHostPort(host); err == nil {
			host = h
		}
		if text, ok := vhosts[strings.ToLower(host)]; ok {
			fmt.Fprintln(w, text)
			return
		}
		fmt.Fprintf(w, "hello from %s\n", name)
	})
	mux.HandleFunc("GET /whoami", func(w http.ResponseWriter, r *http.Request) {
		ip, port, _ := net.SplitHostPort(r.RemoteAddr)
		headers := map[string]string{}
		for k, v := range r.Header {
			headers[k] = strings.Join(v, ", ")
		}
		writeJSON(w, http.StatusOK, map[string]any{
			"server": name, "remote_ip": ip, "remote_port": port, "host": r.Host,
			"method": r.Method, "proto": r.Proto, "tls": r.TLS != nil, "headers": headers,
		})
	})
	mux.HandleFunc("GET /api/status", func(w http.ResponseWriter, r *http.Request) {
		if !strings.Contains(r.Header.Get("Accept"), "application/json") {
			http.Error(w, "406: this endpoint only speaks application/json (check your Accept header)", http.StatusNotAcceptable)
			return
		}
		if r.Header.Get("X-Token") != "netlings" {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "missing or wrong X-Token header"})
			return
		}
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok", "server": name})
	})
	mux.HandleFunc("POST /api/items", func(w http.ResponseWriter, r *http.Request) {
		if ct := r.Header.Get("Content-Type"); !strings.HasPrefix(ct, "application/json") {
			writeJSON(w, http.StatusUnsupportedMediaType, map[string]string{"error": "Content-Type must be application/json, got " + strconv.Quote(ct)})
			return
		}
		var item struct {
			Name string `json:"name"`
		}
		if err := json.UnmarshalRead(io.LimitReader(r.Body, 1<<16), &item); err != nil || item.Name == "" {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": `body must be JSON like {"name": "..."}`})
			return
		}
		writeJSON(w, http.StatusCreated, map[string]any{"id": 42, "name": item.Name})
	})
	mux.HandleFunc("GET /old", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/moved", http.StatusMovedPermanently)
	})
	mux.HandleFunc("GET /moved", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/final", http.StatusFound)
	})
	mux.HandleFunc("GET /final", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "you made it")
	})
	mux.HandleFunc("GET /status/{code}", func(w http.ResponseWriter, r *http.Request) {
		code, err := strconv.Atoi(r.PathValue("code"))
		if err != nil || code < 200 || code > 599 {
			code = http.StatusBadRequest
		}
		w.WriteHeader(code)
		fmt.Fprintln(w, http.StatusText(code))
	})
	mux.HandleFunc("GET /bytes", func(w http.ResponseWriter, r *http.Request) {
		kb, _ := strconv.Atoi(r.URL.Query().Get("kb"))
		kb = min(max(kb, 1), 64*1024)
		w.Header().Set("Content-Length", strconv.Itoa(kb*1024))
		chunk := []byte(strings.Repeat("x", 1024))
		for range kb {
			if _, err := w.Write(chunk); err != nil {
				return
			}
		}
	})
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Server", "netlings/"+name)
		mux.ServeHTTP(w, r)
	})
}

func serveHTTP(addr string, h http.Handler, cfg *tls.Config) error {
	l, err := net.Listen("tcp", addr)
	if err != nil {
		return err
	}
	if cfg != nil {
		l = tls.NewListener(l, cfg)
	}
	srv := &http.Server{Handler: h, ReadHeaderTimeout: 10 * time.Second}
	return srv.Serve(l)
}

// selfSigned makes a throwaway CA and a leaf certificate for hosts, both living only in memory.
func selfSigned(hosts []string, caOut string) (*tls.Config, error) {
	caKey, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, err
	}
	now := time.Now()
	caTmpl := &x509.Certificate{
		SerialNumber:          big.NewInt(1),
		Subject:               pkix.Name{CommonName: "netlings test CA", Organization: []string{"netlings"}},
		NotBefore:             now.Add(-time.Hour),
		NotAfter:              now.Add(24 * time.Hour),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageDigitalSignature,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}
	caDER, err := x509.CreateCertificate(rand.Reader, caTmpl, caTmpl, &caKey.PublicKey, caKey)
	if err != nil {
		return nil, err
	}
	caCert, _ := x509.ParseCertificate(caDER)
	leafKey, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, err
	}
	leafTmpl := &x509.Certificate{
		SerialNumber: big.NewInt(2),
		Subject:      pkix.Name{CommonName: hosts[0], Organization: []string{"netlings"}},
		NotBefore:    now.Add(-time.Hour),
		NotAfter:     now.Add(24 * time.Hour),
		KeyUsage:     x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
	}
	for _, h := range hosts {
		if ip := net.ParseIP(h); ip != nil {
			leafTmpl.IPAddresses = append(leafTmpl.IPAddresses, ip)
		} else if h != "" {
			leafTmpl.DNSNames = append(leafTmpl.DNSNames, h)
		}
	}
	leafDER, err := x509.CreateCertificate(rand.Reader, leafTmpl, caCert, &leafKey.PublicKey, caKey)
	if err != nil {
		return nil, err
	}
	if caOut != "" {
		pemBytes := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: caDER})
		if err := os.WriteFile(caOut, pemBytes, 0o644); err != nil {
			return nil, err
		}
	}
	return &tls.Config{
		Certificates: []tls.Certificate{{Certificate: [][]byte{leafDER, caDER}, PrivateKey: leafKey}},
		NextProtos:   []string{"h2", "http/1.1"},
	}, nil
}

func serveEcho(addr string) error {
	l, err := net.Listen("tcp", addr)
	if err != nil {
		return err
	}
	for {
		c, err := l.Accept()
		if err != nil {
			return err
		}
		go func() {
			defer c.Close()
			sc := bufio.NewScanner(c)
			for sc.Scan() {
				fmt.Fprintln(c, sc.Text())
			}
		}()
	}
}

func serveUDP(addr, out string) error {
	pc, err := net.ListenPacket("udp", addr)
	if err != nil {
		return err
	}
	f, err := os.OpenFile(out, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
	if err != nil {
		return err
	}
	defer f.Close()
	buf := make([]byte, 65535)
	for {
		n, _, err := pc.ReadFrom(buf)
		if err != nil {
			return err
		}
		line := strings.TrimRight(string(buf[:n]), "\r\n")
		fmt.Fprintln(f, line)
	}
}
