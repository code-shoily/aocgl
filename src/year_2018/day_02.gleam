/// Title: Inventory Management System
/// Link: https://adventofcode.com/2018/day/2
/// Difficulty: s
/// Tags: brute-force frequency
import common/reader
import common/solution.{type Solution, OfInt, OfStr, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/result
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfStr

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(List(String))) -> Int {
  input
  |> list.map(fn(letters) {
    letters
    |> get_frequency
    |> dict.fold(#(False, False), fn(acc, _, v) {
      let #(has_two, has_three) = acc
      #(has_two || v == 2, has_three || v == 3)
    })
    |> fn(x) { #(bool_to_num(pair.first(x)), bool_to_num(pair.second(x))) }
  })
  |> list.fold(#(0, 0), fn(acc, x) {
    let #(a, b) = acc
    let #(x, y) = x
    #(a + x, b + y)
  })
  |> fn(x) { pair.first(x) * pair.second(x) }
}

fn solve_part_2(input: List(List(String))) -> String {
  let assert Ok(#(chars1, chars2)) =
    list.combination_pairs(input)
    |> list.find(fn(pair) {
      let #(a, b) = pair
      count_differences(a, b) == 1
    })

  list.zip(chars1, chars2)
  |> list.filter_map(fn(p) {
    case p.0 == p.1 {
      True -> Ok(p.0)
      False -> Error(Nil)
    }
  })
  |> string.join("")
}

fn count_differences(l1: List(String), l2: List(String)) -> Int {
  list.zip(l1, l2)
  |> list.count(fn(p) { p.0 != p.1 })
}

fn bool_to_num(b: Bool) -> Int {
  case b {
    True -> 1
    False -> 0
  }
}

fn parse(raw_input: String) -> List(List(String)) {
  raw_input
  |> utils.to_lines()
  |> list.map(string.to_graphemes)
}

fn get_frequency(letter: List(String)) -> Dict(String, Int) {
  list.fold(letter, dict.new(), fn(acc, x) {
    dict.upsert(acc, x, fn(x) {
      case x {
        Some(x) -> x + 1
        _ -> 1
      }
    })
  })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2018, 2)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
