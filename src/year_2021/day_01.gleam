/// Title: Sonar Sweep
/// Link: https://adventofcode.com/2021/day/1
/// Difficulty: xs
/// Tags: window measurements
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  count_depth_increases(input, 1)
}

fn solve_part_2(input: List(Int)) -> Int {
  count_depth_increases(input, 3)
}

fn parse(raw_input: String) -> List(Int) {
  let assert Ok(nums) = raw_input |> utils.to_lines() |> utils.to_ints()

  nums
}

fn count_depth_increases(depths: List(Int), by: Int) {
  depths
  |> list.window(by)
  |> list.map(int.sum)
  |> list.window_by_2()
  |> list.count(fn(pair) { pair.1 > pair.0 })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2021, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  Nil
}
