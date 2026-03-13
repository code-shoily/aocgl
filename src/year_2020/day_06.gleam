/// Title: Custom Customs
/// Link: https://adventofcode.com/2020/day/6
/// Difficulty: xs
/// Tags: set
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = count_answers_by(input, set.union) |> OfInt
  let part_2 = count_answers_by(input, set.intersection) |> OfInt

  Solution(part_1, part_2)
}

fn count_answers_by(
  answers: List(List(Set(a))),
  set_fun: fn(Set(a), Set(a)) -> Set(a),
) -> Int {
  list.map(answers, fn(answers) {
    list.reduce(answers, fn(acc, x) { set_fun(acc, x) })
    |> result.unwrap(set.new())
  })
  |> list.fold(0, fn(acc, a) { acc + set.size(a) })
}

fn parse(raw_input: String) -> List(List(Set(String))) {
  raw_input
  |> utils.to_paragraphs
  |> list.map(get_answers)
}

fn get_answers(group: String) -> List(Set(String)) {
  group
  |> utils.to_lines
  |> list.map(fn(line) {
    line
    |> string.to_graphemes()
    |> set.from_list
  })
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2020, 6) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
