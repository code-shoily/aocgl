/// Title: 
/// Link: https://adventofcode.com/2023/day/1
/// Difficulty: 
/// Tags: 
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp.{type Regexp, Match}
import gleam/result
import gleam/string

const num_words = [
  "one",
  "two",
  "three",
  "four",
  "five",
  "six",
  "seven",
  "eight",
  "nine",
]

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(String)) -> Int {
  total_calibration(input, [])
}

fn solve_part_2(input: List(String)) -> Int {
  total_calibration(input, num_words)
}

fn total_calibration(entries: List(String), domain: List(String)) -> Int {
  let assert Ok(store) = build_regexp_store(domain)
  entries
  |> list.map(fn(sample) { regex_store_to_entry(sample, store) |> calibration })
  |> list.fold(0, fn(acc, x) { x |> option.unwrap(0) |> int.add(acc) })
}

fn parse(raw_input: String) -> List(String) {
  raw_input
  |> utils.to_lines()
}

type DigitPair =
  #(Option(Int), Option(Int))

type RegexpStore {
  RegexpStore(forward: Regexp, backward: Regexp, mapping: Dict(String, Int))
}

fn calibration(calibrator: DigitPair) -> Option(Int) {
  case calibrator {
    #(Some(first), Some(second)) -> Some(10 * first + second)
    _ -> None
  }
}

fn index_to_num(init: Dict(String, Int), str: List(String)) -> Dict(String, Int) {
  str
  |> list.index_fold(init, fn(mapping, num_word, idx) {
    dict.insert(mapping, num_word, idx + 1)
  })
}

fn build_regexp_store(source: List(String)) -> Result(RegexpStore, Nil) {
  let num_digits = int.range(9, 0, [], fn(acc, x) { [int.to_string(x), ..acc] })
  let num_words_backwards = list.map(source, string.reverse)

  let mapping =
    dict.new()
    |> index_to_num(source)
    |> index_to_num(num_words_backwards)
    |> index_to_num(num_digits)

  let forward =
    source
    |> list.append(num_digits)
    |> string.join("|")
    |> regexp.from_string

  let backward =
    num_words_backwards
    |> list.append(num_digits)
    |> string.join("|")
    |> regexp.from_string

  case forward, backward {
    Ok(forward), Ok(backward) -> Ok(RegexpStore(forward, backward, mapping))
    _, _ -> Error(Nil)
  }
}

fn regex_store_to_entry(document: String, store: RegexpStore) -> DigitPair {
  let RegexpStore(forward: forward, backward: backward, mapping: mapping) =
    store

  let forward_match = regexp.scan(forward, document) |> list.first()
  let backward_match =
    regexp.scan(backward, string.reverse(document)) |> list.first()

  case forward_match, backward_match {
    Ok(Match(a, [])), Ok(Match(b, [])) -> #(
      Some(dict.get(mapping, a) |> result.unwrap(0)),
      Some(dict.get(mapping, b) |> result.unwrap(0)),
    )
    _, _ -> #(None, None)
  }
}

pub fn main() -> Nil {
  let assert Ok(input) =
    reader.InputParams(2023, 1)
    |> reader.read_input()

  solve(input) |> echo

  utils.exit(0)
}
