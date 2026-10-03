// cmd/dockerlings/main.go
package main

import (
	"fmt"
	"log"
	"os"

	"github.com/furkan/dockerlings/internal/cli"
	"github.com/furkan/dockerlings/internal/exercises"
	"github.com/furkan/dockerlings/internal/progress"
	"github.com/furkan/dockerlings/internal/tui"
	"github.com/furkan/dockerlings/internal/util"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/spf13/cobra"
)

// exitCode lets RunE-less commands report failure without cobra printing usage.
var exitCode int

func loadCourse() cli.Course {
	cfg, err := exercises.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load exercises: %v", err)
	}
	prog, err := progress.Load()
	if err != nil {
		log.Fatalf("Failed to load progress: %v", err)
	}
	return cli.Course{Exercises: cfg.Exercises, Progress: prog}
}

func arg(args []string) string {
	if len(args) > 0 {
		return args[0]
	}
	return ""
}

var verifyCmd = &cobra.Command{
	Use:   "verify",
	Short: "Check unfinished exercises in order, stopping at the first one that fails",
	Args:  cobra.NoArgs,
	Run: func(cmd *cobra.Command, args []string) {
		exitCode = loadCourse().Verify()
	},
}

var runCmd = &cobra.Command{
	Use:     "run [ID]",
	Aliases: []string{"check"},
	Short:   "Check one exercise (defaults to the next unfinished one)",
	Args:    cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		exitCode = loadCourse().Run(arg(args))
	},
}

var hintCmd = &cobra.Command{
	Use:   "hint [ID]",
	Short: "Print the hint for an exercise (defaults to the next unfinished one)",
	Args:  cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		exitCode = loadCourse().Hint(arg(args))
	},
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "Show every exercise, its status and the file to edit",
	Args:  cobra.NoArgs,
	Run: func(cmd *cobra.Command, args []string) {
		exitCode = loadCourse().List()
	},
}

var resetCmd = &cobra.Command{
	Use:   "reset ID",
	Short: "Restore an exercise's files to their original state and forget its progress",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		exitCode = loadCourse().Reset(arg(args))
	},
}

var doctorCmd = &cobra.Command{
	Use:   "doctor",
	Short: "Show which external tools are installed and how to get the rest",
	Args:  cobra.NoArgs,
	// Doctor is most useful before the repo is even set up, so it skips the root lookup.
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error { return nil },
	Run: func(cmd *cobra.Command, args []string) {
		exitCode = cli.Doctor()
	},
}

var watchCmd = &cobra.Command{
	Use:   "watch",
	Short: "Interactive TUI that re-checks the current exercise every time you save",
	Args:  cobra.NoArgs,
	Run: func(cmd *cobra.Command, args []string) {
		c := loadCourse()
		model := tui.NewModel(c.Exercises, c.Progress)
		p := tea.NewProgram(
			model,
			tea.WithAltScreen(),
			tea.WithMouseCellMotion(),
		)
		if _, err := p.Run(); err != nil {
			fmt.Printf("There was an error: %v\n", err)
			os.Exit(1)
		}
	},
}

func main() {
	rootCmd := &cobra.Command{
		Use:           "dockerlings",
		Short:         "Learn Docker by fixing small exercises",
		SilenceUsage:  true,
		Args:          cobra.NoArgs,
		PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
			root, err := util.GetProjectRoot()
			if err != nil {
				return err
			}
			return os.Chdir(root)
		},
		Run: verifyCmd.Run,
	}
	rootCmd.AddCommand(verifyCmd, runCmd, hintCmd, listCmd, resetCmd, doctorCmd, watchCmd)

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
	os.Exit(exitCode)
}
