package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
)

// unitPrefix is the only name the course ever creates, stops or removes.
const unitPrefix = "systemdlings-"

func runtimeDir() string {
	if d := os.Getenv("XDG_RUNTIME_DIR"); d != "" {
		return d
	}
	return fmt.Sprintf("/run/user/%d", os.Getuid())
}

// unitDir is in the user manager's search path but lives in tmpfs, so nothing outlives a reboot.
func unitDir() string { return filepath.Join(runtimeDir(), "systemd", "user") }
func dataDir() string { return filepath.Join(runtimeDir(), "systemdlings") }

func userctl(args ...string) (string, error) {
	out, err := exec.Command("systemctl", append([]string{"--user"}, args...)...).CombinedOutput()
	return strings.TrimSpace(string(out)), err
}

func userManagerState() (string, error) {
	out, err := userctl("is-system-running")
	// "degraded" still means the manager answers; a failed unit elsewhere is not our business.
	if out == "running" || out == "degraded" || out == "starting" {
		return out, nil
	}
	if out == "" && err != nil {
		out = err.Error()
	}
	return out, fmt.Errorf("%s", out)
}

// leftovers lists loaded systemdlings-* units and unit files a check failed to remove.
func leftovers() []string {
	var out []string
	if s, err := userctl("list-units", "--all", "--plain", "--no-legend", unitPrefix+"*"); err == nil {
		for line := range strings.Lines(s) {
			if f := strings.Fields(line); len(f) > 0 && strings.HasPrefix(f[0], unitPrefix) {
				out = append(out, f[0])
			}
		}
	}
	entries, _ := os.ReadDir(unitDir())
	for _, e := range entries {
		if strings.HasPrefix(e.Name(), unitPrefix) && !slices.Contains(out, e.Name()) {
			out = append(out, e.Name())
		}
	}
	return out
}

// owned reads the manifest lib.sh keeps for an exercise: "stop PATTERN" and "file NAME" lines.
func owned(exercise string) (stop, files []string) {
	f, err := os.Open(filepath.Join(dataDir(), ".owned", exercise))
	if err != nil {
		return nil, nil
	}
	defer f.Close()
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		kind, name, ok := strings.Cut(sc.Text(), " ")
		if !ok || !strings.HasPrefix(name, unitPrefix) || strings.Contains(name, "/") {
			continue
		}
		switch kind {
		case "stop":
			stop = append(stop, name)
		case "file":
			files = append(files, name)
		}
	}
	return stop, files
}

// sweep stops and removes what a check left behind; exercise "" means every systemdlings-* unit.
func sweep(exercise string) {
	var stop, files []string
	if exercise == "" {
		stop = []string{unitPrefix + "*"}
		entries, _ := os.ReadDir(unitDir())
		for _, e := range entries {
			if strings.HasPrefix(e.Name(), unitPrefix) {
				files = append(files, e.Name())
			}
		}
	} else {
		stop, files = owned(exercise)
	}
	if len(stop) > 0 {
		userctl(append([]string{"stop"}, stop...)...)
		userctl(append([]string{"reset-failed"}, stop...)...)
	}
	for _, f := range files {
		os.RemoveAll(filepath.Join(unitDir(), f))
	}
	if exercise == "" {
		os.RemoveAll(dataDir())
	} else {
		os.RemoveAll(filepath.Join(dataDir(), exercise))
		os.Remove(filepath.Join(dataDir(), ".owned", exercise))
	}
	if len(files) > 0 {
		userctl("daemon-reload")
	}
}

func cmdClean() int {
	left := leftovers()
	sweep("")
	if len(left) == 0 {
		say(green, "nothing to clean: no systemdlings-* units are loaded or installed")
		return 0
	}
	say(yellow, "stopped and removed: %s", strings.Join(left, " "))
	if again := leftovers(); len(again) > 0 {
		say(red, "still there: %s", strings.Join(again, " "))
		return 1
	}
	return 0
}
