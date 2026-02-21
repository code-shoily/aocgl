/// Title: 
/// Link: https://adventofcode.com/2022/day/1
/// Difficulty: 
/// Tags: 
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/order
import gleam/result

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  input |> list.max(with: int.compare) |> result.unwrap(or: 0)
}

fn solve_part_2(input: List(Int)) -> Int {
  input
  |> list.sort(by: order.reverse(int.compare))
  |> list.take(3)
  |> int.sum()
}

fn parse(raw_input: String) -> List(Int) {
  raw_input
  |> utils.to_paragraphs()
  |> list.map(fn(paragraph) {
    paragraph
    |> utils.to_lines()
    |> utils.to_ints()
    |> result.unwrap(or: [])
    |> int.sum()
  })
}

pub fn main() -> Nil {
  let param = reader.InputParams(2022, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  Nil
}
