/// Title: Corruption Checksum
/// Link: https://adventofcode.com/2017/day/2
/// Difficulty: s
/// Tags: transpose checksum
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(List(Int))) -> Int {
  input
  |> list.map(min_max_diff)
  |> int.sum
}

fn solve_part_2(input: List(List(Int))) -> Int {
  input
  |> list.map(list.sort(_, int.compare))
  |> list.map(divides_each_other(_, None))
  |> int.sum
}

fn parse(raw_input: String) -> List(List(Int)) {
  raw_input
  |> utils.to_lines()
  |> list.map(fn(line) {
    let assert Ok(row) = line |> string.split("\t") |> utils.to_ints
    row
  })
}

fn min_max_diff(nums: List(Int)) -> Int {
  let assert Ok(#(min, max)) = case nums {
    [] -> Error(Nil)
    [first, ..rest] -> {
      Ok(
        list.fold(rest, #(first, first), fn(acc, n) {
          #(int.min(acc.0, n), int.max(acc.1, n))
        }),
      )
    }
  }

  max - min
}

fn divides_each_other(nums: List(Int), result: Option(Int)) -> Int {
  case nums, result {
    _, Some(result) -> result
    [_, ..rest] as xs, _ -> {
      case divides_any(xs) {
        Some(_) as found -> divides_each_other([], found)
        _ -> divides_each_other(rest, None)
      }
    }
    _, _ -> panic as "Must have a pair"
  }
}

fn divides_any(xs: List(Int)) -> Option(Int) {
  case xs {
    [y, z, ..] if z % y == 0 -> Some(z / y)
    [y, _, ..rest] -> divides_any([y, ..rest])
    [] | [_] -> None
  }
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2017, 2)
  let input = reader.read_input(param) |> result.unwrap(or: "")

  input
  |> solve
  |> echo

  utils.exit(0)
}
