/// Title: Digital Plumber
/// Link: https://adventofcode.com/2017/day/12
/// Difficulty: s
/// Tags: graph scc
import common/reader
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
  // Find the group that contains node 0 and return its size
  groups
  |> list.find(fn(group) { list.contains(group, 0) })
  |> result.map(list.length)
  |> result.unwrap(0)
}

fn solve_part_2(groups: List(List(Int))) -> Int {
  list.length(groups)
}

fn parse(raw_input: String) -> yog.Graph(Nil, Nil) {
  raw_input
  |> utils.to_lines()
  |> list.fold(yog.undirected(), fn(graph, line) {
    let assert [source_str, targets_str] = string.split(line, " <-> ")
    let assert Ok(source) = int.parse(source_str)

    targets_str
    |> string.split(", ")
    |> list.fold(graph, fn(g, target_str) {
      let assert Ok(target) = int.parse(target_str)
      g
      |> yog.add_node(source, Nil)
      |> yog.add_edge(from: target, to: source, with: Nil)
    })
  })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2017, 12)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
