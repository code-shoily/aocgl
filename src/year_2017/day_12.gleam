/// Title: Digital Plumber
/// Link: https://adventofcode.com/2017/day/12
/// Difficulty: s
/// Tags: graph scc
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import yog
import yog/components

pub fn solve(raw_input: String) -> Solution {
  let graph = parse(raw_input)
  let groups = components.strongly_connected_components(graph)

  let part_1 = solve_part_1(groups) |> OfInt
  let part_2 = solve_part_2(groups) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(groups: List(List(Int))) -> Int {
  groups
  |> list.find(fn(group) { list.contains(group, 0) })
  |> result.map(list.length)
  |> result.unwrap(0)
}

fn solve_part_2(groups: List(List(Int))) -> Int {
  list.length(groups)
}

fn parse(raw_input: String) -> yog.Graph(Nil, Nil) {
  let lines = utils.to_lines(raw_input)

  use core_graph, line <- list.fold(lines, yog.undirected())

  let assert [source_str, targets_str] = string.split(line, " <-> ")
  let assert Ok(source) = int.parse(source_str)
  let tokens = string.split(targets_str, ", ")

  use acc_graph, target_str <- list.fold(tokens, core_graph)

  let assert Ok(target) = int.parse(target_str)

  acc_graph
  |> yog.add_node(source, Nil)
  |> yog.add_edge(from: target, to: source, with: Nil)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}
//
// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2017, 12) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
