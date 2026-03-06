/// Title: The Sum of Its Parts
/// Link: https://adventofcode.com/2018/day/7
/// Difficulty: m
/// Tags: graph topological-sort
import common/solution.{type Solution, OfNil, OfStr, Solution}
import common/utils
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import yog.{type Graph}
import yog/builder/labeled
import yog/topological_sort

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfStr
  let part_2 = solve_part_2(input) |> OfNil

  Solution(part_1, part_2)
}

fn solve_part_1(input: Graph(String, Nil)) -> String {
  let assert Ok(order) =
    topological_sort.lexicographical_topological_sort(input, string.compare)

  order
  |> list.map(dict.get(input.nodes, _))
  |> list.map(result.unwrap(_, ""))
  |> string.join("")
}

fn solve_part_2(_input: Graph(String, Nil)) -> Nil {
  Nil
}

fn parse(raw_input: String) -> Graph(String, Nil) {
  raw_input
  |> utils.to_lines()
  |> list.map(parse_line)
  |> list.fold(labeled.directed(), fn(labeled_graph, dep) {
    let #(prereq, step) = dep
    labeled.add_unweighted_edge(labeled_graph, prereq, step)
  })
  |> labeled.to_graph()
}

fn parse_line(line: String) -> #(String, String) {
  let words = string.split(line, " ")

  let assert Ok(prereq) = utils.at(words, 1)
  let assert Ok(step) = utils.at(words, 7)

  #(prereq, step)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2018, 7) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
