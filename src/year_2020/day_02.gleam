/// Title: Password Philosophy
/// Link: https://adventofcode.com/2020/day/2
/// Difficulty: xs
/// Tags: text security
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = list.count(input, is_valid_1) |> OfInt
  let part_2 = list.count(input, is_valid_2) |> OfInt

  Solution(part_1, part_2)
}

fn parse(raw_input: String) -> List(Policy) {
  let assert Ok(re) = regexp.from_string("^(\\d+)-(\\d+) (.): (.+)$")

  raw_input
  |> utils.to_lines()
  |> list.map(parse_line(_, re))
}

fn parse_line(line: String, re: regexp.Regexp) -> Policy {
  let assert [Match(_, [Some(i), Some(f), Some(c), Some(pwd)])] =
    regexp.scan(re, line)
  Policy(definitely_int(i), definitely_int(f), c, pwd)
}

fn definitely_int(i: String) -> Int {
  let assert Ok(i) = int.parse(i)
  i
}

fn is_valid_1(policy: Policy) -> Bool {
  let Policy(i, f, c, pwd) = policy

  let count = pwd |> string.to_graphemes |> list.count(fn(char) { char == c })
  count >= i && count <= f
}

fn is_valid_2(policy: Policy) -> Bool {
  let Policy(i, f, c, pwd) = policy
  let pwd = string.to_graphemes(pwd)

  case utils.at(pwd, i - 1), utils.at(pwd, f - 1) {
    Ok(x), Ok(y) -> {
      { x == c } != { y == c }
    }
    _, _ -> False
  }
}

type Policy {
  Policy(i: Int, f: Int, c: String, pwd: String)
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2020, 2)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
