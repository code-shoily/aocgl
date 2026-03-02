/// Title: A Long Walk
/// Link: https://adventofcode.com/2023/day/23
/// Difficulty: l
/// Tags: graph implicit-graph longest-path dfs bitmask
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Grid =
  Dict(Int, String)

fn is_valid(grid: Grid, p: Int) -> Bool {
  case dict.get(grid, p) {
    Ok("#") | Error(_) -> False
    _ -> True
  }
}

fn get_neighbors(p: Int, grid: Grid, width: Int, part: Int) -> List(Int) {
  let up = p - width
  let down = p + width
  let left = p - 1
  let right = p + 1

  case part {
    1 -> {
      case dict.get(grid, p) {
        Ok("^") -> [up]
        Ok("v") -> [down]
        Ok("<") -> [left]
        Ok(">") -> [right]
        _ -> [up, down, left, right]
      }
    }
    _ -> [up, down, left, right]
  }
  |> list.filter(fn(np) { is_valid(grid, np) })
}

fn find_intersections(
  grid: Grid,
  width: Int,
  start: Int,
  goal: Int,
) -> List(Int) {
  dict.fold(grid, [], fn(acc, p, v) {
    case v {
      "#" -> acc
      _ -> {
        let n = get_neighbors(p, grid, width, 2)
        case list.length(n) > 2 || p == start || p == goal {
          True -> [p, ..acc]
          False -> acc
        }
      }
    }
  })
}

// Graph of { intersection_id -> List(#(neighbor_id, distance)) }
type Graph =
  Dict(Int, List(#(Int, Int)))

fn walk_corridor(
  curr: Int,
  prev: Int,
  dist: Int,
  grid: Grid,
  width: Int,
  part: Int,
  is_intersection: fn(Int) -> Bool,
) -> Result(#(Int, Int), Nil) {
  case is_intersection(curr) {
    True -> Ok(#(curr, dist))
    False -> {
      let nexts =
        get_neighbors(curr, grid, width, part)
        |> list.filter(fn(n) { n != prev })

      case nexts {
        [next] ->
          walk_corridor(
            next,
            curr,
            dist + 1,
            grid,
            width,
            part,
            is_intersection,
          )
        [] -> Error(Nil)
        // Dead end
        _ -> Error(Nil)
        // Too many nexts, should only happen at intersections.
      }
    }
  }
}

// Build the implicit graph into an explicit one showing weights
fn build_graph(
  intersections: List(Int),
  grid: Grid,
  width: Int,
  part: Int,
) -> Graph {
  // Map index for bitmasks
  let node_to_id =
    intersections
    |> list.index_map(fn(node, idx) { #(node, idx) })
    |> dict.from_list()

  let is_intersection = fn(p: Int) { dict.has_key(node_to_id, p) }

  intersections
  |> list.fold(dict.new(), fn(graph, start_node) {
    let start_id = dict.get(node_to_id, start_node) |> result.unwrap(-1)

    // For a given start_node, what other intersections can it reach natively?
    let edges =
      get_neighbors(start_node, grid, width, part)
      |> list.filter_map(fn(first_step) {
        let res =
          walk_corridor(
            first_step,
            start_node,
            1,
            grid,
            width,
            part,
            is_intersection,
          )

        case res {
          Ok(#(end_node, dist)) -> {
            let end_id = dict.get(node_to_id, end_node) |> result.unwrap(-1)
            Ok(#(end_id, dist))
          }
          Error(_) -> Error(Nil)
        }
      })

    dict.insert(graph, start_id, edges)
  })
}

fn dfs(curr: Int, goal: Int, visited: Int, cost: Int, graph: Graph) -> Int {
  case curr == goal {
    True -> cost
    False -> {
      let neighbors = dict.get(graph, curr) |> result.unwrap([])

      neighbors
      |> list.fold(-1, fn(max_cost, edge) {
        let #(next_id, edge_cost) = edge
        // Is next_id in visited bitmask?
        let is_visited =
          int.bitwise_and(visited, int.bitwise_shift_left(1, next_id)) != 0
        case is_visited {
          True -> max_cost
          False -> {
            let new_visited =
              int.bitwise_or(visited, int.bitwise_shift_left(1, next_id))
            let path_cost =
              dfs(next_id, goal, new_visited, cost + edge_cost, graph)
            int.max(max_cost, path_cost)
          }
        }
      })
    }
  }
}

fn solve_part(grid: Grid, width: Int, height: Int, part: Int) -> Int {
  let start = 1
  // Assuming top row is #.# with . at index 1
  let goal = { height - 1 } * width + { width - 2 }
  // bottom row

  let intersections = find_intersections(grid, width, start, goal)
  let graph = build_graph(intersections, grid, width, part)

  let node_to_id =
    intersections
    |> list.index_map(fn(node, idx) { #(node, idx) })
    |> dict.from_list()

  let start_id = dict.get(node_to_id, start) |> result.unwrap(-1)
  let goal_id = dict.get(node_to_id, goal) |> result.unwrap(-1)

  // --- THE PRUNING TRICK ---
  // The start only has one neighbor.
  let outgoing_from_start = dict.get(graph, start_id) |> result.unwrap([])
  let #(first_junction_id, dist_from_start) = case outgoing_from_start {
    [#(next_id, dist)] -> #(next_id, dist)
    _ -> #(start_id, 0)
  }

  // The goal only has one incoming neighbor. We find it safely for both directed/undirected.
  let incoming_to_goal =
    dict.fold(graph, [], fn(acc, u, edges) {
      case list.find(edges, fn(e) { e.0 == goal_id }) {
        Ok(#(_, dist)) -> [#(u, dist), ..acc]
        Error(_) -> acc
      }
    })
  let #(final_junction_id, dist_to_goal) = case incoming_to_goal {
    [#(prev_id, dist)] -> #(prev_id, dist)
    _ -> #(goal_id, 0)
  }

  let initial_visited = int.bitwise_shift_left(1, first_junction_id)

  // We set the DFS target to the final junction, NOT the goal.
  let max_path_to_junction =
    dfs(first_junction_id, final_junction_id, initial_visited, 0, graph)

  // Add the initial and final stretch to the result
  max_path_to_junction + dist_from_start + dist_to_goal
}

pub fn solve(raw_input: String) -> Solution {
  let #(grid, width, height) = parse(raw_input)

  let part_1 = solve_part(grid, width, height, 1) |> OfInt
  let part_2 = solve_part(grid, width, height, 2) |> OfInt

  Solution(part_1, part_2)
}

fn parse(raw_input: String) -> #(Grid, Int, Int) {
  let lines = utils.to_lines(raw_input)
  let height = list.length(lines)
  let width = case list.first(lines) {
    Ok(line) -> string.length(line)
    Error(_) -> 0
  }

  let grid =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes()
      |> list.index_map(fn(char, x) { #(y * width + x, char) })
    })
    |> list.flatten()
    |> dict.from_list()

  #(grid, width, height)
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2023, 23)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
