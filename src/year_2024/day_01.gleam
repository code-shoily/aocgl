/// Title: 
/// Link: https://adventofcode.com/2024/day/1
/// Difficulty: 
/// Tags: 
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: #(List(Int), List(Int))) -> Int {
  list.sort(pair.first(input), int.compare)
  |> list.zip(list.sort(pair.second(input), int.compare))
  |> list.map(fn(x) { int.absolute_value(pair.second(x) - pair.first(x)) })
  |> int.sum
}

fn solve_part_2(input: #(List(Int), List(Int))) -> Int {
  let frequency_map = build_frequency_map(pair.second(input))

  input
  |> pair.first()
  |> list.map(fn(n) { n * result.unwrap(dict.get(frequency_map, n), 0) })
  |> int.sum
}

fn parse(raw_input: String) -> #(List(Int), List(Int)) {
  raw_input
  |> utils.to_lines()
  |> list.map(line_to_nums)
  |> result.all
  |> result.unwrap([])
  |> list.unzip
}

fn line_to_nums(line: String) -> Result(#(Int, Int), Nil) {
  let pair = string.split(line, "   ") |> list.map(int.parse)
  case pair {
    [Ok(left), Ok(right)] -> Ok(#(left, right))
    _ -> Error(Nil)
  }
}

fn build_frequency_map(nums: List(Int)) -> Dict(Int, Int) {
  nums
  |> list.group(function.identity)
  |> dict.map_values(fn(_, v) { list.length(v) })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2024, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")

  echo solve(input)

  utils.exit(0)
}
