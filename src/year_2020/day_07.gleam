/// Title: Handy Haversacks
/// Link: https://adventofcode.com/2020/day/7
/// Difficulty: s
/// Tags: graph bfs
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import yog
import yog/builder/labeled.{type Builder}
import yog/transform
import yog/traversal.{BreadthFirst}

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(builder: Builder(String, Int)) -> Int {
  let assert Ok(shiny_gold_id) = labeled.get_id(builder, "shiny gold")
  let graph = labeled.to_graph(builder)
  let transposed = transform.transpose(graph)
  let containers =
    traversal.walk(from: shiny_gold_id, in: transposed, using: BreadthFirst)

  list.length(list.unique(containers)) - 1
}

fn solve_part_2(builder: Builder(String, Int)) -> Int {
  let assert Ok(shiny_gold_id) = labeled.get_id(builder, "shiny gold")
  let graph = labeled.to_graph(builder)

  count_bags_inside(graph, shiny_gold_id)
}

fn count_bags_inside(graph: yog.Graph(String, Int), node_id: yog.NodeId) -> Int {
  yog.successors(graph, node_id)
  |> list.fold(0, fn(total, edge) {
    let #(child_id, count) = edge
    // count bags + (count * bags inside those bags)
    total + count + count * count_bags_inside(graph, child_id)
  })
}

fn parse(raw_input: String) -> Builder(String, Int) {
  raw_input
  |> utils.to_lines()
  |> list.fold(labeled.directed(), fn(builder, line) {
    let assert [parent, contents] = string.split(line, " bags contain ")
    let child_parts = string.split(contents, ", ")

    list.fold(child_parts, builder, fn(g, part) {
      let #(count, child) = parse_content_part(part)
      labeled.add_edge(g, parent, child, count)
    })
  })
}

fn parse_content_part(part: String) -> #(Int, String) {
  // Simple parsing logic to extract "1" and "bright white"
  let part = string.replace(part, ".", "")
  case string.split(part, " ") {
    [count_str, adj, color, _bag_suffix] -> {
      let count = int.parse(count_str) |> result.unwrap(0)
      #(count, adj <> " " <> color)
    }
    _ -> #(0, "")
  }
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2020, 7)
  let input = reader.read_input(param) |> result.unwrap(or: "")

  input
  |> solve()
  |> echo

  utils.exit(0)
}
