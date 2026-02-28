/// Title: Universal Orbit Map
/// Link: https://adventofcode.com/2019/day/6
/// Difficulty: l
/// Tags: graph shortest-path
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
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

  case
    pathfinding.shortest_path(
      in: graph,
      from: you_id,
      to: san_id,
      with_zero: 0,
      with_add: int.add,
      with_compare: int.compare,
    )
  {
    Some(path) -> path.total_weight - 2
    None -> -1
  }
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
  let children = yog.successors(graph, node_id)

  depth
  + list.fold(children, 0, fn(total, edge) {
    let #(child_id, _weight) = edge
    total + count_total_orbits(graph, child_id, depth + 1)
  })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2019, 6)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  input |> solve() |> echo

  utils.exit(0)
}
