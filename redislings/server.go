package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strconv"
	"syscall"
)

// cmdServer runs a foreground scratch server so learners can try commands without touching a real instance.
func cmdServer(args []string) int {
	fl := flag.NewFlagSet("server", flag.ContinueOnError)
	port := fl.Int("port", 6390, "port to listen on (127.0.0.1 only)")
	if err := fl.Parse(args); err != nil {
		return 2
	}
	srv, cli, err := lookRedis()
	if err != nil {
		say(red, "%v", err)
		fmt.Println("  " + installHint("redis"))
		return 1
	}
	dir, err := os.MkdirTemp("", "redislings-server-")
	if err != nil {
		say(red, "%v", err)
		return 1
	}
	defer os.RemoveAll(dir)

	say(green, "scratch server on 127.0.0.1:%d (nothing is saved to disk; Ctrl-C to stop)", *port)
	fmt.Printf("  connect:      %s -p %d\n", filepath.Base(cli), *port)
	fmt.Printf("  run a file:   grep -v '^#' exercises/01_strings/strings1/commands.redis | %s -p %d\n\n", filepath.Base(cli), *port)

	cmd := exec.Command(srv,
		"--port", strconv.Itoa(*port), "--bind", "127.0.0.1",
		"--save", "", "--appendonly", "no", "--dir", dir,
		"--loglevel", "warning")
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
	if err := cmd.Start(); err != nil {
		say(red, "%v", err)
		return 1
	}
	// Forward Ctrl-C / SIGTERM so the server never outlives us.
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		for s := range sigs {
			cmd.Process.Signal(s)
		}
	}()
	cmd.Wait()
	return 0
}
