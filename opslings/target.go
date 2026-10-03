package main

import (
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"encoding/json/jsontext"
	"encoding/json/v2"
	"uuid"
)

const (
	targetUser = "ops"
	targetPass = "lings"
)

type item struct {
	ID    int     `json:"id"`
	Name  string  `json:"name"`
	Price float64 `json:"price"`
}

var items = []item{
	{1, "pager", 49.99},
	{2, "coffee", 3.50},
	{3, "runbook", 0},
	{4, "rubber duck", 7.25},
	{5, "on-call pizza", 18},
}

// target is the small HTTP API that the k6 and caddy checks exercise.
type target struct {
	mu     sync.Mutex
	counts map[string]int
	authed int
	flaky  int
	tokens map[string]string
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (s *statusRecorder) WriteHeader(code int) {
	s.status = code
	s.ResponseWriter.WriteHeader(code)
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.MarshalWrite(w, v, jsontext.WithIndentPrefix(""), jsontext.WithIndent("  "))
	w.Write([]byte("\n"))
}

func (t *target) routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "hello from the opslings target")
	})
	mux.HandleFunc("GET /api/items", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, items)
	})
	mux.HandleFunc("GET /api/items/{id}", func(w http.ResponseWriter, r *http.Request) {
		id, _ := strconv.Atoi(r.PathValue("id"))
		for _, it := range items {
			if it.ID == id {
				writeJSON(w, http.StatusOK, it)
				return
			}
		}
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "no such item"})
	})
	mux.HandleFunc("POST /api/login", func(w http.ResponseWriter, r *http.Request) {
		var creds struct {
			Username string `json:"username"`
			Password string `json:"password"`
		}
		if err := json.UnmarshalRead(r.Body, &creds); err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "send a JSON body like {\"username\": \"...\", \"password\": \"...\"}"})
			return
		}
		if creds.Username != targetUser || creds.Password != targetPass {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "bad credentials"})
			return
		}
		tok := uuid.New().String()
		t.mu.Lock()
		t.tokens[tok] = creds.Username
		t.mu.Unlock()
		writeJSON(w, http.StatusOK, map[string]string{"token": tok})
	})
	mux.HandleFunc("GET /api/me", func(w http.ResponseWriter, r *http.Request) {
		tok, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
		t.mu.Lock()
		user, known := t.tokens[tok]
		if ok && known {
			t.authed++
		}
		t.mu.Unlock()
		if !ok || !known {
			w.Header().Set("WWW-Authenticate", "Bearer")
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "missing or unknown bearer token"})
			return
		}
		writeJSON(w, http.StatusOK, map[string]string{"username": user})
	})
	mux.HandleFunc("GET /slow", func(w http.ResponseWriter, r *http.Request) {
		ms, _ := strconv.Atoi(r.URL.Query().Get("ms"))
		time.Sleep(time.Duration(min(max(ms, 0), 5000)) * time.Millisecond)
		fmt.Fprintf(w, "slept %dms\n", ms)
	})
	mux.HandleFunc("GET /flaky", func(w http.ResponseWriter, r *http.Request) {
		t.mu.Lock()
		t.flaky++
		n := t.flaky
		t.mu.Unlock()
		if n%3 == 0 {
			http.Error(w, "flaked", http.StatusInternalServerError)
			return
		}
		fmt.Fprintln(w, "ok")
	})
	mux.HandleFunc("GET /__stats", func(w http.ResponseWriter, r *http.Request) {
		t.mu.Lock()
		defer t.mu.Unlock()
		total := 0
		for _, n := range t.counts {
			total += n
		}
		writeJSON(w, http.StatusOK, map[string]any{"requests": t.counts, "authed": t.authed, "total": total})
	})
	mux.HandleFunc("POST /__reset", func(w http.ResponseWriter, r *http.Request) {
		t.mu.Lock()
		t.counts = map[string]int{}
		t.authed, t.flaky = 0, 0
		t.mu.Unlock()
		w.WriteHeader(http.StatusNoContent)
	})

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		mux.ServeHTTP(rec, r)
		// ServeMux fills in r.Pattern, which keeps /api/items/{id} to a single key.
		path := r.URL.Path
		if _, p, ok := strings.Cut(r.Pattern, " "); ok {
			path = strings.TrimSuffix(p, "{$}")
		}
		if strings.HasPrefix(path, "/__") {
			return
		}
		t.mu.Lock()
		t.counts[fmt.Sprintf("%s %s %d", r.Method, path, rec.status)]++
		t.mu.Unlock()
	})
}

func cmdTarget(args []string) int {
	fl := flag.NewFlagSet("target", flag.ContinueOnError)
	port := fl.Int("port", 8080, "port to listen on (127.0.0.1 only)")
	quiet := fl.Bool("quiet", false, "do not print the banner")
	if err := fl.Parse(args); err != nil {
		return 2
	}
	t := &target{counts: map[string]int{}, tokens: map[string]string{}}
	l, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", *port))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	if !*quiet {
		fmt.Printf(`opslings target listening on http://%s
  GET  /                     plain text greeting
  GET  /api/items            JSON list
  GET  /api/items/{id}       one item, 404 if unknown
  POST /api/login            {"username":%q,"password":%q} -> {"token": ...}
  GET  /api/me               needs "Authorization: Bearer <token>", else 401
  GET  /slow?ms=N            sleeps N ms (max 5000)
  GET  /flaky                every 3rd request is a 500
  GET  /__stats              request counts by "METHOD path status"
  POST /__reset              zero the counters
`, l.Addr(), targetUser, targetPass)
	}
	srv := &http.Server{Handler: t.routes(), ReadHeaderTimeout: 10 * time.Second}
	if err := srv.Serve(l); err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	return 0
}
