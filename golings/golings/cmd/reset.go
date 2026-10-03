package cmd

import (
	"os"

	"github.com/fatih/color"
	"github.com/mauricioabreu/golings/golings/exercises"
	"github.com/spf13/cobra"
)

func ResetCmd(infoFile string) *cobra.Command {
	return &cobra.Command{
		Use:   "reset <exercise name>",
		Short: "Restore an exercise to its original, unsolved state",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			exercise, err := exercises.Find(args[0], infoFile)
			if err != nil {
				color.Red("No exercise found for '%s'", args[0])
				return err
			}
			data, err := os.ReadFile(exercise.TemplatePath())
			if err != nil {
				color.Red("No pristine copy at %s", exercise.TemplatePath())
				return err
			}
			if err := os.WriteFile(exercise.Path, data, 0o644); err != nil {
				return err
			}
			color.Yellow("Reset %s to its original state", exercise.Name)
			return nil
		},
	}
}
