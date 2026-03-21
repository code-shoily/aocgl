/// Title: High-Entropy Passphrases
/// Link: https://adventofcode.com/2017/day/4
/// Difficulty: xs 
/// Tags: list
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/list.{Continue, Stop}
import gleam/set
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(List(String))) -> Int {
  input |> list.count(fn(words) { !has_duplicates(words) })
}

fn solve_part_2(input: List(List(String))) -> Int {
  input |> list.map(list.map(_, sort_word)) |> solve_part_1()
}

fn sort_word(word: String) -> String {
  word |> string.to_graphemes |> list.sort(string.compare) |> string.join("")
}

fn has_duplicates(words: List(String)) -> Bool {
  let #(_, found) = {
    use #(word_set, _), word <- list.fold_until(words, #(set.new(), False))
    case set.contains(word_set, word) {
      True -> Stop(#(set.new(), True))
      False -> Continue(#(set.insert(word_set, word), False))
    }
  }

  found
}

fn parse(raw_input: String) -> List(List(String)) {
  raw_input
  |> utils.to_lines()
  |> list.map(string.split(_, " "))
}

// ------------------------------ Exploration
import common/reader.{InputParams}

pub fn main() -> Nil {
  let assert Ok(input) = InputParams(2017, 4) |> reader.read_input
  input |> utils.timed(solve) |> echo

  utils.exit(0)
}
