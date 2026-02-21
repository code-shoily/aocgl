/// Title: Not Quite Lisp (2015/1)
/// Link: https://adventofcode.com/2015/day/1
/// Difficulty: xs
/// Tags: navigation linear-scan reduction
import common/solution.{type Solution, OfInt, Solution}
import gleam/int
import gleam/list
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  int.sum(input)
}

fn solve_part_2(input: List(Int)) -> Int {
  get_to_basement(input, 0, 0)
}

fn parse(raw_input: String) -> List(Int) {
  raw_input
  |> string.to_graphemes()
  |> list.map(fn(s) {
    case s {
      "(" -> 1
      ")" -> -1
      _ -> panic as "I must suck at parsing"
    }
  })
}

fn get_to_basement(movements: List(Int), current, steps) -> Int {
  case current, movements {
    -1, _ -> steps
    _, [this_step, ..remaining] ->
      get_to_basement(remaining, current + this_step, steps + 1)
    _, [] -> panic as "Santa never reached the basement!"
  }
}
