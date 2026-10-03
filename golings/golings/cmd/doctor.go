package cmd

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

func DoctorCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "doctor",
		Short: "Show which external tools are installed and how to get the rest",
		RunE: func(cmd *cobra.Command, args []string) error {
			goBin, err := exec.LookPath("go")
			if err != nil {
				fmt.Printf("%s go           install go: https://go.dev/dl/\n", color.RedString("missing"))
				return errors.New("go is not installed")
			}
			out, _ := exec.Command(goBin, "env", "GOVERSION").Output()
			have := strings.TrimPrefix(strings.TrimSpace(string(out)), "go")
			fmt.Printf("%s go           %s (%s)\n", color.GreenString("ok     "), goBin, have)
			if want := requiredGo(); want != "" && versionLess(have, want) {
				color.Red("go %s is older than the go %s that go.mod asks for; update it from https://go.dev/dl/", have, want)
				return errors.New("go is too old")
			}
			if p, err := exec.LookPath("gopls"); err == nil {
				fmt.Printf("%s gopls        %s %s\n", color.GreenString("ok     "), p, color.HiBlackString("(optional: editor support)"))
			} else {
				fmt.Printf("%s gopls        go install golang.org/x/tools/gopls@latest %s\n", color.YellowString("missing"), color.HiBlackString("(optional: editor support)"))
			}
			fmt.Println()
			color.Green("Everything golings needs is installed.")
			return nil
		},
	}
}

func requiredGo() string {
	data, err := os.ReadFile("go.mod")
	if err != nil {
		return ""
	}
	for _, line := range strings.Split(string(data), "\n") {
		if line = strings.TrimSpace(line); strings.HasPrefix(line, "go ") {
			return strings.TrimSpace(strings.TrimPrefix(line, "go "))
		}
	}
	return ""
}

// versionLess compares dotted Go versions numerically; pre-release suffixes are ignored.
func versionLess(a, b string) bool {
	pa, pb := strings.Split(a, "."), strings.Split(b, ".")
	for i := 0; i < len(pa) || i < len(pb); i++ {
		var x, y int
		if i < len(pa) {
			fmt.Sscanf(pa[i], "%d", &x)
		}
		if i < len(pb) {
			fmt.Sscanf(pb[i], "%d", &y)
		}
		if x != y {
			return x < y
		}
	}
	return false
}
