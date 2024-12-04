package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

const test_input = `
3   4
4   3
2   5
1   3
3   9
3   3
`

func main() {
	input, err := os.ReadFile("input/day01.txt")
	if err != nil {
		panic(err)
	}
	day1_p1(test_input)
	day1_p1(string(input))
	day1_p2(test_input)
	day1_p2(string(input))
}

func day1_p1(input string) {
	lefts, rights := []int{}, []int{}
	for _, line := range strings.Split(input, "\n") {
		if line == "" {
			continue
		}

		l, r := splitLine(line)
		lefts = append(lefts, l)
		rights = append(rights, r)
	}

	slices.Sort(lefts)
	slices.Sort(rights)

	offset := 0
	for i := range len(lefts) {
		l, r := lefts[i], rights[i]
		d := l - r
		if d < 0 {
			d = -d
		}
		offset += d
	}

	fmt.Println("Day 1: ", offset)
}

func day1_p2(input string) {
	lefts, rights := []int{}, []int{}
	for _, line := range strings.Split(input, "\n") {
		if line == "" {
			continue
		}

		l, r := splitLine(line)
		lefts = append(lefts, l)
		rights = append(rights, r)
	}

	slices.Sort(lefts)
	slices.Sort(rights)

	score := 0
	l_i, r_i := 0, 0
	for l_i < len(lefts) {
		l := lefts[l_i]

		count := 0
		for r_i < len(rights) && rights[r_i] <= l {
			r := rights[r_i]
			r_i += 1
			if l == r {
				count += 1
			}
		}
		for l_i < len(lefts) && lefts[l_i] == l {
			score += l * count
			l_i += 1
		}
	}

	fmt.Println("Day 1: ", score)
}

func splitLine(line string) (int, int) {
	parts := strings.Split(line, "   ")
	l, err := strconv.Atoi(parts[0])
	if err != nil {
		panic(err)
	}
	r, err := strconv.Atoi(parts[1])
	if err != nil {
		panic(err)
	}
	return l, r
}
