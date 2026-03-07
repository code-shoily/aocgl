/// Title: Handy Haversacks
/// Link: https://adventofcode.com/2020/day/7
/// Difficulty: s
/// Tags: graph bfs
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
  let nodes = graph |> yog.successors(node_id)
  use total, #(child_id, count) <- list.fold(nodes, 0)
  total + count + count * count_bags_inside(graph, child_id)
}

fn parse(raw_input: String) -> Builder(String, Int) {
  let lines = utils.to_lines(raw_input)

  use builder, line <- list.fold(lines, labeled.directed())

  let assert [parent, contents] = string.split(line, " bags contain ")
  let child_parts = string.split(contents, ", ")

  use g, part <- list.fold(child_parts, builder)

  let #(count, child) = parse_content_part(part)
  labeled.add_edge(g, parent, child, count)
}

fn parse_content_part(part: String) -> #(Int, String) {
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
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2020, 7) |> reader.read_input

//   input
//   |> utils.timed(solve)
//   |> echo

//   utils.exit(0)
// }
