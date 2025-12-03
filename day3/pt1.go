package main

import (
	"fmt"
	"io"
	"os"
	"strings"
)

func maxJoltage(line string) int {
	values := make([]int, len(line))
	for i, c := range line {
		values[i] = int(c - '0')
	}
	first := 0
	for i := first; i < len(values)-1; i++ {
		if values[i] > values[first] {
			first = i
		}
	}
	second := first + 1
	for i := second; i < len(values); i++ {
		if values[i] > values[second] {
			second = i
		}
	}
	result := 10*values[first] + values[second]
	fmt.Println(
		"searching bank", line, "\t",
		"first", values[first], " (", first, ") \t",
		"second", values[second], " (", second, ")\t",
		"sum", result,
	)
	return result
}

func main() {
	stdin, err := io.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}
	input := string(stdin)
	lines := strings.Split(input, "\n")
	accum := 0
	for _, line := range lines {
		if len(line) == 0 {
			continue
		}
		accum += maxJoltage(line)
	}
	fmt.Println("accum:", accum)
}
