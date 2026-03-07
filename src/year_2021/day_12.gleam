/// Title: Passage Pathing
/// Link: https://adventofcode.com/2021/day/12
/// Difficulty: m
/// Tags: graph dfs backtracking
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict
import gleam/list
import gleam/set.{type Set}
import gleam/string
import yog/builder/labeled
import yog/model.{type Graph}

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: #(Graph(String, Nil), Int)) -> Int {
  let #(graph, start_id) = input
  count_paths(graph, start_id, set.new(), False)
}

fn solve_part_2(input: #(Graph(String, Nil), Int)) -> Int {
  let #(graph, start_id) = input
  count_paths(graph, start_id, set.new(), True)
}

fn count_paths(
  graph: model.Graph(String, Nil),
  current: Int,
  visited_small: Set(String),
  can_revisit_one: Bool,
) -> Int {
  let assert Ok(cave_name) = dict.get(graph.nodes, current)

  case cave_name {
    "end" -> 1

    _ -> {
      let successors = model.successors(graph, current)
      use count, #(neighbor_id, _) <- list.fold(successors, 0)

      let assert Ok(neighbor_name) = dict.get(graph.nodes, neighbor_id)
      let is_small = neighbor_name == string.lowercase(neighbor_name)
      let already_visited = set.contains(visited_small, neighbor_name)

      case neighbor_name, is_small, already_visited, can_revisit_one {
        "start", _, _, _ -> count
        _, True, True, True ->
          count + count_paths(graph, neighbor_id, visited_small, False)
        _, True, True, False -> count
        _, True, False, _ -> {
          let new_visited = set.insert(visited_small, neighbor_name)
          count + count_paths(graph, neighbor_id, new_visited, can_revisit_one)
        }
        _, _, _, _ ->
          count
          + count_paths(graph, neighbor_id, visited_small, can_revisit_one)
      }
    }
  }
}

fn parse(raw_input: String) -> #(Graph(String, Nil), Int) {
  let edges =
    raw_input
    |> utils.to_lines()
    |> list.map(fn(line) {
      let assert [from, to] = string.split(line, "-")
      #(from, to)
    })

  let builder = {
    use builder, #(from, to) <- list.fold(edges, labeled.undirected())
    labeled.add_unweighted_edge(builder, from, to)
  }

  let graph = labeled.to_graph(builder)
  let assert Ok(start_id) = labeled.get_id(builder, "start")

  #(graph, start_id)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() {
//   let assert Ok(input) = InputParams(2021, 12) |> reader.read_input
//   input |> utils.timed(solve) |> echo
//   echo utils.exit(0)
// }
