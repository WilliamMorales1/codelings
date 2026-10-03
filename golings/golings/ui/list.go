package ui

import (
	"fmt"
	"io"

	"github.com/fatih/color"
	"github.com/mauricioabreu/golings/golings/exercises"
)

func PrintList(o io.Writer, exs []exercises.Exercise) {
	done := 0
	for _, ex := range exs {
		label := color.YellowString("PENDING")
		if ex.State() == exercises.Done {
			label = color.GreenString("DONE   ")
			done++
		}
		fmt.Fprintf(o, "%s  %-28s %s\n", label, ex.Name, FileLink(ex.Path))
	}
	fmt.Fprintln(o)
	fmt.Fprintln(o, ProgressBar(done, len(exs)))
}
