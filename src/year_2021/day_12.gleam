/// Title: Passage Pathing
/// Link: https://adventofcode.com/2021/day/12
/// Difficulty: m
/// Tags: graph dfs backtracking
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import yog/builder/labeled
import yog/model

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> Int {
  let Input(graph, start_id) = input
  count_paths(graph, start_id, set.new(), False)
}

fn solve_part_2(input: Input) -> Int {
  let Input(graph, start_id) = input
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
      model.successors(graph, current)
      |> list.fold(0, fn(count, neighbor) {
        let #(neighbor_id, _) = neighbor
        let assert Ok(neighbor_name) = dict.get(graph.nodes, neighbor_id)

        let is_small = is_small_cave(neighbor_name)
        let already_visited = set.contains(visited_small, neighbor_name)

        case neighbor_name {
          "start" -> count
          _ -> {
            case is_small, already_visited, can_revisit_one {
              True, True, True ->
                count + count_paths(graph, neighbor_id, visited_small, False)
              True, True, False -> count
              True, False, _ -> {
                let new_visited = set.insert(visited_small, neighbor_name)
                count
                + count_paths(graph, neighbor_id, new_visited, can_revisit_one)
              }
              False, _, _ ->
                count
                + count_paths(
                  graph,
                  neighbor_id,
                  visited_small,
                  can_revisit_one,
                )
            }
          }
        }
      })
    }
  }
}

fn is_small_cave(name: String) -> Bool {
  name == string.lowercase(name)
}

type Input {
  Input(graph: model.Graph(String, Nil), start_id: Int)
}

fn parse(raw_input: String) -> Input {
  let edges =
    raw_input
    |> utils.to_lines()
    |> list.map(fn(line) {
      let assert [from, to] = string.split(line, "-")
      #(from, to)
    })

  let builder =
    edges
    |> list.fold(labeled.undirected(), fn(b, edge) {
      let #(from, to) = edge
      labeled.add_unweighted_edge(b, from, to)
    })

  let graph = labeled.to_graph(builder)
  let assert Ok(start_id) = labeled.get_id(builder, "start")

  Input(graph, start_id)
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2021, 12)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo
  echo utils.exit(0)
}
