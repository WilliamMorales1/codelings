package cmd

import (
	"os"

	"github.com/fatih/color"
	"github.com/mauricioabreu/golings/golings/exercises"
	"github.com/spf13/cobra"
)

func HintCmd(infoFile string) *cobra.Command {
	return &cobra.Command{
		Use:   "hint [next | <exercise name>]",
		Short: "Get a hint for an exercise",
		Args:  cobra.MaximumNArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			var exercise exercises.Exercise
			var err error
			if len(args) == 0 || args[0] == "next" {
				exercise, err = exercises.NextPending(infoFile)
			} else {
				exercise, err = exercises.Find(args[0], infoFile)
			}

			if err != nil {
				color.Red(err.Error())
				os.Exit(1)
			}
			color.Yellow(exercise.Hint)
		},
	}
}
