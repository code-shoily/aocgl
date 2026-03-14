/// Title: Squares With Three Sides
/// Link: https://adventofcode.com/2016/day/3
/// Difficulty: xs
/// Tags: transpose geometry
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/list
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(List(Int))) -> Int {
  input |> list.count(is_triangle)
}

fn solve_part_2(input: List(List(Int))) -> Int {
  input
  |> list.transpose()
  |> list.flatten()
  |> list.sized_chunk(3)
  |> list.count(is_triangle)
}

fn parse(raw_input: String) -> List(List(Int)) {
  raw_input
  |> utils.to_lines()
  |> list.map(parse_line)
}

fn parse_line(line: String) -> List(Int) {
  let assert Ok([a, b, c]) =
    line
    |> string.split(" ")
    |> list.filter(fn(ch) { !string.is_empty(ch) })
    |> utils.to_ints

  [a, b, c]
}

fn is_triangle(vals: List(Int)) {
  let assert [a, b, c] = vals

  a + b > c && b + c > a && c + a > b
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2016, 3) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
