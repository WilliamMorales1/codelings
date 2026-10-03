// Package exercises
package exercises

import (
	"fmt"

	"github.com/spf13/viper"
)

type Exercise struct {
	ID        string `mapstructure:"id"`
	Title     string `mapstructure:"title"`
	Track     string `mapstructure:"track"`
	DependsOn string `mapstructure:"depends_on"`
}

type Config struct {
	Exercises []Exercise `mapstructure:"exercises"`
}

// LoadConfig finds, loads, and parses the dockerlings.toml file.
func LoadConfig() (*Config, error) {
	viper.AddConfigPath(".")
	viper.SetConfigName("dockerlings")
	viper.SetConfigType("toml")

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			return nil, fmt.Errorf("config file not found: dockerlings.toml")
		}
		return nil, fmt.Errorf("error reading config file: %w", err)
	}

	var config Config

	if err := viper.Unmarshal(&config); err != nil {
		return nil, fmt.Errorf("unable to decode config into struct: %w", err)
	}

	return &config, nil
}
