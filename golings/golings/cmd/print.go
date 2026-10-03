package cmd

import (
	"errors"
	"fmt"
	"os"

	"github.com/fatih/color"
	"github.com/mauricioabreu/golings/golings/exercises"
	"github.com/mauricioabreu/golings/golings/ui"
)

func PrintHint(infoFile string) {
	ui.ClearScreen()
	exercise, err := exercises.NextPending(infoFile)
	if err != nil {
		color.Red("Failed to find next exercises")
	}
	color.Yellow(exercise.Hint)
}

func PrintList(infoFile string) {
	ui.ClearScreen()
	exs, err := exercises.List(infoFile)
	if err != nil {
		color.Red("Failed to list exercises")
	}
	ui.PrintList(os.Stdout, exs)
}

func RunNextExercise(infoFile string) {
	ui.ClearScreen()

	exercise, err := exercises.NextPending(infoFile)
	_, done, total, perr := exercises.Progress(infoFile)
	if perr != nil {
		fmt.Fprintln(os.Stderr, perr)
	} else {
		fmt.Println(ui.ProgressBar(done, total))
		fmt.Println()
	}

	if errors.Is(err, exercises.ErrNoPendingExercises) {
		color.Green("Congratulations!!\n")
		color.Green("You have completed all %d of the currently available exercises.", total)
		color.Blue("If you enjoyed working through this introduction to Golang,")
		color.Blue("please give the github repository a star")
		color.White("> https://github.com/mauricioabreu/golings <\n\n\n")
		color.Yellow("To quit out of watch, please type `exit` and hit enter:")
		return
	}
	if err != nil {
		color.Red("Failed to find next exercises")
	}

	result, err := exercise.Run()
	if err != nil {
		color.Red("x %s fails.", result.Exercise.Name)
		fmt.Printf("  File: %s\n\n", ui.FileLink(result.Exercise.Path))
		color.Red(result.Err)
		color.Red(result.Out)
		color.Yellow("If you feel stuck, type `hint` and hit enter")
	}
	fmt.Println()
	color.HiBlack("watching... type `hint`, `list` or `quit` and hit enter")
}
