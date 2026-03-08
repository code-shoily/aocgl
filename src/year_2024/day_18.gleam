/// Title: RAM Run
/// Link: https://adventofcode.com/2024/day/18
/// Difficulty: m
/// Tags: graph shortest-path grid
import common/solution.{type Solution, OfInt, OfStr, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import yog/builder/grid
import yog/model.{type Graph}
import yog/pathfinding/dijkstra as pathfinding

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfStr

  Solution(part_1, part_2)
}

const dim = 71

fn solve_part_1(coords: List(#(Int, Int))) -> Int {
  let take_count = 1024
  let corrupted = list.take(coords, take_count) |> set.from_list

  let grid_2d =
    utils.int_range(0, dim - 1)
    |> list.map(fn(y) {
      utils.int_range(0, dim - 1)
      |> list.map(fn(x) { set.contains(corrupted, #(x, y)) })
    })

  let grid_builder =
    grid.from_2d_list(grid_2d, model.Undirected, fn(from_corr, to_corr) {
      !from_corr && !to_corr
    })

  let graph = grid.to_graph(grid_builder)
  let start = grid.coord_to_id(0, 0, dim)
  let end = grid.coord_to_id(dim - 1, dim - 1, dim)

  case pathfinding.shortest_path_int(graph, start, end) {
    Some(path) -> path.total_weight
    None -> 0
  }
}

fn solve_part_2(coords: List(#(Int, Int))) -> String {
  let empty_grid =
    list.map(utils.int_range(0, dim - 1), fn(_) { list.repeat(False, dim) })

  let builder =
    grid.from_2d_list(empty_grid, model.Undirected, fn(_, _) { True })

  let initial_graph = grid.to_graph(builder)
  let start = grid.coord_to_id(0, 0, dim)
  let end = grid.coord_to_id(dim - 1, dim - 1, dim)

  let assert Ok(bad_coord) = find_blocker(initial_graph, coords, start, end, [])
  int.to_string(bad_coord.0) <> "," <> int.to_string(bad_coord.1)
}

fn find_blocker(
  graph: Graph(Bool, Int),
  remaining_coords: List(#(Int, Int)),
  start: Int,
  end: Int,
  current_path: List(Int),
) -> Result(#(Int, Int), Nil) {
  case remaining_coords {
    [] -> Error(Nil)
    [coord, ..rest] -> {
      let #(x, y) = coord
      let id = grid.coord_to_id(y, x, dim)
      let next_graph = model.remove_node(graph, id)
      let path_broken = current_path == [] || list.contains(current_path, id)

      case path_broken {
        True -> {
          case pathfinding.shortest_path_int(next_graph, start, end) {
            Some(path) -> find_blocker(next_graph, rest, start, end, path.nodes)
            None -> Ok(coord)
          }
        }
        False -> {
          find_blocker(next_graph, rest, start, end, current_path)
        }
      }
    }
  }
}

fn parse(raw_input: String) -> List(#(Int, Int)) {
  raw_input
  |> utils.to_lines()
  |> list.filter(fn(l) { string.trim(l) != "" })
  |> list.map(fn(line) {
    let assert Ok(#(x_str, y_str)) = string.split_once(line, ",")
    let assert Ok(x) = int.parse(string.trim(x_str))
    let assert Ok(y) = int.parse(string.trim(y_str))
    #(x, y)
  })
}
// -------------------------------- Explore
// import common/reader.{InputParams}

// pub fn main() {
//   let assert Ok(input) = InputParams(2024, 18) |> reader.read_input

//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
