/// Title: Snowverload
/// Link: https://adventofcode.com/2023/day/25
/// Difficulty: xl
/// Tags: graph min-cut stoer-wagner
import common/reader
import common/solution.{type Solution, OfDay25, OfInt, Solution}
import common/utils
import gleam/list
import gleam/result
import gleam/string
import yog/builder/labeled
import yog/min_cut
import yog/model

pub fn solve(raw_input: String) -> Solution {
  let graph = parse(raw_input)
  let part_1 = solve_part_1(graph) |> OfInt

  Solution(part_1, OfDay25(Nil))
}

fn solve_part_1(graph: model.Graph(String, Int)) -> Int {
  let result = min_cut.global_min_cut(graph)

  result.group_a_size * result.group_b_size
}

fn parse(raw_input: String) -> model.Graph(String, Int) {
  raw_input
  |> utils.to_lines()
  |> list.fold(labeled.undirected(), fn(builder, line) {
    case string.split(line, on: ": ") {
      [source, dests] -> {
        string.split(dests, on: " ")
        |> list.fold(builder, fn(b, target) {
          labeled.add_edge(b, from: source, to: target, with: 1)
        })
      }
      _ -> builder
    }
  })
  |> labeled.to_graph()
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2023, 25)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
