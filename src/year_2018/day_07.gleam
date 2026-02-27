/// Title: The Sum of Its Parts
/// Link: https://adventofcode.com/2018/day/7
/// Difficulty: m
/// Tags: graph topological-sort
import common/reader
import common/solution.{type Solution, OfNil, OfStr, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import yog/model
import yog/topological_sort

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfStr
  let part_2 = solve_part_2(input) |> OfNil

  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> String {
  let Input(graph) = input

  let assert Ok(order) =
    topological_sort.lexicographical_topological_sort(graph, int.compare)

  order
  |> list.map(ascii_to_char)
  |> string.join("")
}

fn solve_part_2(_input: Input) -> Nil {
  Nil
}

type Input {
  Input(graph: model.Graph(Nil, Nil))
}

fn parse(raw_input: String) -> Input {
  let dependencies =
    raw_input
    |> utils.to_lines()
    |> list.map(parse_line)

  let graph =
    dependencies
    |> list.fold(model.new(model.Directed), fn(g, dep) {
      let #(prereq, step) = dep
      let prereq_id = char_to_ascii(prereq)
      let step_id = char_to_ascii(step)

      g
      |> model.add_node(prereq_id, Nil)
      |> model.add_node(step_id, Nil)
      |> model.add_edge(from: prereq_id, to: step_id, with: Nil)
    })

  Input(graph)
}

fn parse_line(line: String) -> #(String, String) {
  let words = string.split(line, " ")

  let assert Ok(prereq) = utils.at(words, 1)
  let assert Ok(step) = utils.at(words, 7)

  #(prereq, step)
}

fn char_to_ascii(s: String) -> Int {
  let assert Ok(codepoint) = string.to_utf_codepoints(s) |> list.first
  string.utf_codepoint_to_int(codepoint)
}

fn ascii_to_char(code: Int) -> String {
  let assert Ok(codepoint) = string.utf_codepoint(code)
  string.from_utf_codepoints([codepoint])
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2018, 7)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
