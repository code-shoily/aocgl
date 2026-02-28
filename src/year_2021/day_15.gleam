/// Title: Chiton
/// Link: https://adventofcode.com/2021/day/15
/// Difficulty: m
/// Tags: graph shortest-path grid dijkstra
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import yog/builder/grid
import yog/model
import yog/pathfinding

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(grid_2d: List(List(Int))) -> Int {
  let builder = grid.from_2d_list(grid_2d, model.Directed, fn(_, _) { True })
  let cols = list.length(result.unwrap(list.first(grid_2d), []))
  let rows = list.length(grid_2d)

  let base_graph = grid.to_graph(builder)

  let new_out_edges =
    dict.map_values(base_graph.out_edges, fn(_src, neighbors) {
      dict.map_values(neighbors, fn(dst, _weight) {
        let assert Ok(dest_data) = dict.get(base_graph.nodes, dst)
        dest_data
      })
    })

  let graph = model.Graph(..base_graph, out_edges: new_out_edges)

  let start = grid.coord_to_id(0, 0, cols)
  let end = grid.coord_to_id(rows - 1, cols - 1, cols)

  // Just standard Dijkstra on the Grid
  case pathfinding.shortest_path(graph, start, end, 0, int.add, int.compare) {
    Some(path) -> path.total_weight
    None -> -1
  }
}

fn solve_part_2(grid_2d: List(List(Int))) -> Int {
  let cols = list.length(result.unwrap(list.first(grid_2d), []))
  let rows = list.length(grid_2d)

  // Expand grid 5x5
  let expanded_grid =
    utils.int_range(0, rows * 5 - 1)
    |> list.map(fn(r) {
      utils.int_range(0, cols * 5 - 1)
      |> list.map(fn(c) {
        let base_r = r % rows
        let base_c = c % cols
        let offset = r / rows + c / cols
        let assert Ok(base_row) = utils.at(grid_2d, base_r)
        let assert Ok(base_val) = utils.at(base_row, base_c)

        let new_val = base_val + offset
        case new_val > 9 {
          True -> new_val - 9
          False -> new_val
        }
      })
    })

  let big_cols = cols * 5
  let big_rows = rows * 5

  let builder =
    grid.from_2d_list(expanded_grid, model.Directed, fn(_, _) { True })
  let base_graph = grid.to_graph(builder)

  let new_out_edges =
    dict.map_values(base_graph.out_edges, fn(_src, neighbors) {
      dict.map_values(neighbors, fn(dst, _weight) {
        let assert Ok(dest_data) = dict.get(base_graph.nodes, dst)
        dest_data
      })
    })

  let graph = model.Graph(..base_graph, out_edges: new_out_edges)

  let start = grid.coord_to_id(0, 0, big_cols)
  let end = grid.coord_to_id(big_rows - 1, big_cols - 1, big_cols)

  // We have the Manhattan heuristic so we can use A* to make traversing the 500x500 grid insanely fast!
  let h = fn(node_id, goal_id) {
    let nx = node_id % big_cols
    let ny = node_id / big_cols
    let gx = goal_id % big_cols
    let gy = goal_id / big_cols
    int.absolute_value(nx - gx) + int.absolute_value(ny - gy)
  }

  case
    pathfinding.a_star(graph, start, end, 0, int.add, int.compare, heuristic: h)
  {
    Some(path) -> path.total_weight
    None -> -1
  }
}

fn parse(raw_input: String) -> List(List(Int)) {
  raw_input
  |> utils.to_lines()
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> list.filter_map(int.parse)
  })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2021, 15)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
