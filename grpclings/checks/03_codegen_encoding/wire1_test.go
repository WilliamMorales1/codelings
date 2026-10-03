//go:build check

package wire1

import (
	"slices"
	"testing"
)

func TestAnswers(t *testing.T) {
	type q struct {
		name string
		ok   bool
	}
	for _, c := range []q{
		{"Q1Field", Q1Field == 1}, {"Q1WireType", Q1WireType == 0}, {"Q1Value", Q1Value == 150},
		{"Q2Field", Q2Field == 2}, {"Q2WireType", Q2WireType == 2}, {"Q2Length", Q2Length == 7}, {"Q2Text", Q2Text == "testing"},
		{"Q3Value", Q3Value == -2},
		{"Q4TotalBytes", Q4TotalBytes == 11}, {"Q4Value", Q4Value == -1},
		{"Q5Values", slices.Equal(Q5Values, []int{1, 2, 3})},
		{"Q6Fields", slices.Equal(Q6Fields, []int{1, 2, 3})}, {"Q6LastWireType", Q6LastWireType == 5}, {"Q6LastFloat", Q6LastFloat == 1.0},
	} {
		if !c.ok {
			t.Errorf("%s is not right yet", c.name)
		}
	}
}
