/// Title: Doesn't He Have Intern-Elves For This?
/// Link: https://adventofcode.com/2015/day/5
/// Difficulty: s
/// Tags: list
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/set
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(List(String))) -> Int {
  list.count(
    input,
    solver([has_three_vowels, has_repeated_chars, has_no_naughty_pair]),
  )
}

fn solve_part_2(input: List(List(String))) -> Int {
  list.count(input, solver([has_repeating_pairs, has_sandwitched_triple]))
}

fn solver(preds: List(fn(str) -> Bool)) {
  fn(value) -> Bool {
    preds
    |> list.all(fn(pred) { pred(value) })
  }
}

fn has_three_vowels(letters: List(String)) -> Bool {
  let vowels = set.from_list(["a", "e", "i", "o", "u"])

  letters
  |> list.fold_until(0, fn(count, letter) {
    case set.contains(vowels, letter), count >= 3 {
      _, True -> Stop(count)
      True, _ -> Continue(count + 1)
      _, _ -> Continue(count)
    }
  })
  >= 3
}

fn has_repeated_chars(letters: List(String)) -> Bool {
  letters
  |> list.window_by_2
  |> list.any(fn(pair) { pair.0 == pair.1 })
}

fn has_no_naughty_pair(letters: List(String)) -> Bool {
  let naughty_list = set.from_list(["ab", "cd", "pq", "xy"])

  letters
  |> list.window_by_2
  |> list.map(fn(pair) { pair.0 <> pair.1 })
  |> list.fold_until(True, fn(_, pair) {
    case set.contains(naughty_list, pair) {
      True -> Stop(False)
      False -> Continue(True)
    }
  })
}

fn has_repeating_pairs(letters: List(String)) -> Bool {
  case letters {
    [a, b, ..rest] -> {
      let pair = a <> b
      let exists_later = string.contains(string.join(rest, ""), pair)

      exists_later || has_repeating_pairs([b, ..rest])
    }
    _ -> False
  }
}

fn has_sandwitched_triple(letters: List(String)) -> Bool {
  letters
  |> list.window(3)
  |> list.any(fn(triple) {
    list.first(triple) == list.last(triple) && result.is_ok(list.first(triple))
  })
}

fn parse(raw_input: String) -> List(List(String)) {
  use line <- list.map(utils.to_lines(raw_input))
  string.to_graphemes(line)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2015, 5) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
