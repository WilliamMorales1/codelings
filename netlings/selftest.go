package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

type selfResult struct {
	skipped  []string // missing tools
	problems []string
	took     time.Duration
}

// selftestOne runs a check against the solution (must pass) and the untouched template (must fail).
func selftestOne(e Exercise, scratch string) selfResult {
	start := time.Now()
	var r selfResult
	if m := missingTools(e.Requires()); len(m) > 0 {
		r.skipped = m
		return r
	}
	for _, d := range []string{e.SolutionDir(), e.TemplateDir(), e.Dir()} {
		if st, err := os.Stat(d); err != nil || !st.IsDir() {
			r.problems = append(r.problems, "missing directory "+d)
		}
	}
	if len(r.problems) > 0 {
		return r
	}

	sol := filepath.Join(scratch, e.Chapter+"-"+e.Name+"-solution")
	if err := copyTree(e.SolutionDir(), sol); err != nil {
		r.problems = append(r.problems, err.Error())
		return r
	}
	if ok, out := runCheck(e, sol); !ok {
		r.problems = append(r.problems, "SOLUTION FAILS:\n"+out)
	}

	ex := filepath.Join(scratch, e.Chapter+"-"+e.Name+"-exercise")
	if err := copyTree(e.TemplateDir(), ex); err != nil {
		r.problems = append(r.problems, err.Error())
		return r
	}
	if ok, out := runCheck(e, ex); ok {
		r.problems = append(r.problems, "EXERCISE PASSES WITHOUT CHANGES:\n"+out)
	}
	r.took = time.Since(start)
	return r
}

func cmdSelftest(root string, exs []Exercise, jobs int) int {
	scratch, err := os.MkdirTemp("", "netlings-selftest-")
	if err != nil {
		say(red, "%v", err)
		return 1
	}
	defer os.RemoveAll(scratch)

	results := make([]selfResult, len(exs))
	sem := make(chan struct{}, jobs)
	var wg sync.WaitGroup
	for i, e := range exs {
		wg.Go(func() {
			sem <- struct{}{}
			defer func() { <-sem }()
			results[i] = selftestOne(e, scratch)
		})
	}
	wg.Wait()

	bad, skipped := 0, 0
	for i, e := range exs {
		r := results[i]
		switch {
		case len(r.skipped) > 0:
			skipped++
			say(yellow, "SKIPPED %s (missing: %s)", e.ID(), strings.Join(r.skipped, " "))
		case len(r.problems) > 0:
			bad++
			say(red, "BROKEN  %s", e.ID())
			for _, p := range r.problems {
				indent(p)
			}
		default:
			fmt.Printf("%s %s %s\n", paint(green, "ok     "), e.ID(), paint(dim, r.took.Round(10*time.Millisecond).String()))
		}
	}
	fmt.Println()
	fmt.Printf("%d exercises: %d ok, %d skipped, %d broken\n", len(exs), len(exs)-bad-skipped, skipped, bad)
	if bad > 0 {
		return 1
	}
	if skipped > 0 {
		say(yellow, "Not everything was verified: install the missing tools to check the skipped chapters.")
	}
	return 0
}
