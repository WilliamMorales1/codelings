package cmd

import (
	"errors"
	"os"
	"path/filepath"
	"strings"

	"github.com/fatih/color"

	"github.com/spf13/cobra"
)

func NewRootCmd(version string) *cobra.Command {
	rootCmd := &cobra.Command{
		Use:           "golings",
		Short:         "Learn go through interactive exercises",
		SilenceUsage:  true,
		SilenceErrors: true,
		Args:          cobra.NoArgs,
		Version:       version,
		PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
			return chdirToRoot("info.toml")
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			verify := VerifyCmd("info.toml")
			verify.Run(verify, args)
			return nil
		},
	}

	rootCmd.AddCommand(HintCmd("info.toml"))
	rootCmd.AddCommand(ListCmd("info.toml"))
	rootCmd.AddCommand(RunCmd("info.toml"))
	rootCmd.AddCommand(VerifyCmd("info.toml"))
	rootCmd.AddCommand(WatchCmd("info.toml"))
	rootCmd.AddCommand(ResetCmd("info.toml"))
	rootCmd.AddCommand(DoctorCmd())

	return rootCmd
}

func Execute(version string) {
	if err := NewRootCmd(version).Execute(); err != nil {
		if strings.HasPrefix(err.Error(), "unknown command") {
			color.Red(err.Error())
		}
		os.Exit(1)
	}
}

// chdirToRoot walks up from the working directory to the one holding infoFile, so golings works from any subdirectory.
func chdirToRoot(infoFile string) error {
	dir, err := os.Getwd()
	if err != nil {
		return err
	}
	for {
		if _, err := os.Stat(filepath.Join(dir, infoFile)); err == nil {
			return os.Chdir(dir)
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return errors.New("could not find info.toml; run golings from inside the golings repository")
		}
		dir = parent
	}
}
