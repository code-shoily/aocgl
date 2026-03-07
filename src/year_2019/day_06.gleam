/// Title: Universal Orbit Map
/// Link: https://adventofcode.com/2019/day/6
/// Difficulty: l
/// Tags: graph shortest-path
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/string
import yog.{type Graph, type NodeId}
import yog/builder/labeled.{type Builder}
import yog/pathfinding

pub fn solve(raw_input: String) -> Solution {
  let directed_builder = parse(raw_input, labeled.directed())
  let undirected_builder = parse(raw_input, labeled.undirected())

  let part_1 = solve_part_1(directed_builder) |> OfInt
  let part_2 = solve_part_2(undirected_builder) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(builder: Builder(String, Int)) -> Int {
  let assert Ok(com_id) = labeled.get_id(builder, "COM")
  let graph = labeled.to_graph(builder)

  count_total_orbits(graph, com_id, 0)
}

fn solve_part_2(builder: Builder(String, Int)) -> Int {
  let assert Ok(you_id) = labeled.get_id(builder, "YOU")
  let assert Ok(san_id) = labeled.get_id(builder, "SAN")
  let graph = labeled.to_graph(builder)

  let assert Some(path) =
    pathfinding.shortest_path(
      in: graph,
      from: you_id,
      to: san_id,
      with_zero: 0,
      with_add: int.add,
      with_compare: int.compare,
    )

  path.total_weight - 2
}

fn parse(raw_input: String, init_graph) -> Builder(String, Int) {
  raw_input
  |> utils.to_lines()
  |> list.fold(init_graph, fn(builder, line) {
    let assert [center, orbiter] = string.split(line, ")")
    labeled.add_simple_edge(builder, center, orbiter)
  })
}

fn count_total_orbits(
  graph: Graph(String, Int),
  node_id: NodeId,
  depth: Int,
) -> Int {
  depth
  + {
    use total, #(child_id, _) <- list.fold(yog.successors(graph, node_id), 0)
    total + count_total_orbits(graph, child_id, depth + 1)
  }
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() {
//   let assert Ok(input) = InputParams(2019, 6) |> reader.read_input
//   input |> utils.timed(solve) |> echo
// }
