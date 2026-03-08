/// Title: Four-Dimensional Adventure
/// Link: https://adventofcode.com/2018/day/25
/// Difficulty: s
/// Tags: graph scc
import common/solution.{type Solution, OfInt, OfNil, Solution}
import gleam/int
import gleam/list
import gleam/string
import yog.{type Graph}
import yog/connectivity

pub type Point =
  #(Int, Int, Int, Int)

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let graph = build_graph(input)
  let components = connectivity.strongly_connected_components(graph)

  let part_1 = list.length(components) |> OfInt

  Solution(part_1, OfNil(Nil))
}

fn build_graph(points: List(Point)) -> Graph(Point, Int) {
  let initial =
    list.index_fold(points, yog.undirected(), fn(acc, point, idx) {
      yog.add_node(acc, idx, point)
    })

  let indexed_points = list.index_map(points, fn(p, idx) { #(idx, p) })

  list.combination_pairs(indexed_points)
  |> list.fold(initial, fn(graph, pair) {
    let #(#(idx1, p1), #(idx2, p2)) = pair
    case manhattan(p1, p2) <= 3 {
      True -> yog.add_edge(graph, from: idx1, to: idx2, with: 1)
      False -> graph
    }
  })
}

fn manhattan(p1: Point, p2: Point) -> Int {
  int.absolute_value(p1.0 - p2.0)
  + int.absolute_value(p1.1 - p2.1)
  + int.absolute_value(p1.2 - p2.2)
  + int.absolute_value(p1.3 - p2.3)
}

fn parse(raw_input: String) -> List(Point) {
  raw_input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [a, b, c, d] =
      line
      |> string.split(",")
      |> list.map(string.trim)
      |> list.filter_map(int.parse)
    #(a, b, c, d)
  })
}
// ------------------------------ Exploration
// import common/reader.{InputParams}
// import common/utils

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2018, 25) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
