/// Title: Inverse Captcha
/// Link: https://adventofcode.com/2017/day/1
/// Difficulty: xs
/// Tags: linked-list captcha
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  input |> add_around() |> matches_next() |> int.sum()
}

fn solve_part_2(input: List(Int)) -> Int {
  let len = list.length(input)
  let #(first_half, second_half) = list.split(input, len / 2)

  list.zip(first_half, second_half)
  |> list.filter(fn(pair) { pair.0 == pair.1 })
  |> list.map(fn(pair) { pair.0 })
  |> int.sum()
  |> int.multiply(2)
}

fn parse(raw_input: String) -> List(Int) {
  let assert Ok(digits) =
    raw_input
    |> string.to_graphemes()
    |> utils.to_ints()

  digits
}

fn add_around(digits: List(Int)) -> List(Int) {
  case digits {
    [] -> []
    [head, ..tail] ->
      tail |> list.reverse() |> list.prepend(head) |> list.reverse()
  }
}

fn matches_next(digits: List(Int)) -> List(Int) {
  do_matches_next(digits, [])
}

fn do_matches_next(digits: List(Int), result: List(Int)) -> List(Int) {
  case digits {
    [] -> result
    [h1, h2, ..rest] if h1 == h2 ->
      do_matches_next([h2, ..rest], [h1, ..result])
    [_, ..rest] -> do_matches_next(rest, result)
  }
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2017, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  echo solve(input)

  Nil
}
