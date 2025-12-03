package main

import (
	"fmt"
	"io"
	"math"
	"os"
	"strings"
)

func maxJoltage(line string) int {
	values := make([]int, len(line))
	for i, c := range line {
		values[i] = int(c - '0')
	}

	k := 12
	result_idxs := make([]int, k)
	for i := 0; i < k; i++ {
		idx := 0
		if i > 0 {
			idx = result_idxs[i-1] + 1
		}
		// i = 0 -> iter until len(values) - k + 1
		// i = n -> iter until len(values) - (k - n) + 1
		upper := len(values) - (k - i) + 1
		for j := idx; j < upper; j++ {
			if values[j] > values[idx] {
				idx = j
			}
		}
		result_idxs[i] = idx
	}

	result := 0
	for i := 0; i < k; i++ {
		// i = 0 -> 10 ** k - 1
		// i = 1 -> 10 ** k - 2
		// i = n -> 10 ** k - n - 1
		mult := int(math.Pow(10.0, float64(k-i-1)))
		result += mult * values[result_idxs[i]]
	}
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
