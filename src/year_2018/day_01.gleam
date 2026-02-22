/// Title: Chronal Calibration
/// Link: https://adventofcode.com/2018/day/1
/// Difficulty: xs
/// Tags: set circular-list
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/result
import gleam/set.{type Set}

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
  traverse_frequencies(input, input, 0, set.from_list([]))
}

fn parse(raw_input: String) -> List(Int) {
  let assert Ok(nums) =
    raw_input
    |> utils.to_lines()
    |> utils.to_ints()

  nums
}

fn traverse_frequencies(
  xs: List(Int),
  ys: List(Int),
  freq: Int,
  visited: Set(Int),
) -> Int {
  case xs {
    [cur, ..rest] -> {
      let freq = freq + cur
      case set.contains(visited, freq) {
        True -> freq
        False -> traverse_frequencies(rest, ys, freq, set.insert(visited, freq))
      }
    }
    [] -> traverse_frequencies(ys, ys, freq, visited)
  }
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2018, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  Nil
}
