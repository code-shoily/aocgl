/// Title: Pipe Maze
/// Link: https://adventofcode.com/2023/day/10
/// Difficulty: xl
/// Tags: graph bfs grid
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import yog/builder/grid
import yog/model
import yog/pathfinding

pub type Cell {
  Cell(row: Int, col: Int, char: String)
}

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt
  // Part 2 stub

  Solution(part_1, part_2)
}

fn solve_part_1(grid_2d: List(List(Cell))) -> Int {
  // To avoid writing manual bounds checking and grid topology,
  // we use Yog.Builder.Grid! We only connect cells if their pipes match.
  let is_connected = fn(from_cell: Cell, to_cell: Cell) {
    can_connect(from_cell, to_cell)
  }

  // Directed ensures we only follow valid pipe flow,
  // Undirected would be fine if our can_connect was perfectly bilateral
  let builder = grid.from_2d_list(grid_2d, model.Directed, is_connected)
  let graph = grid.to_graph(builder)

  let cols = list.length(result.unwrap(list.first(grid_2d), []))

  // Find 'S' coordinate to start
  let start_node_id =
    list.flatten(grid_2d)
    |> list.find(fn(c) { c.char == "S" })
    |> result.unwrap(Cell(0, 0, "S"))
    |> fn(c) { grid.coord_to_id(c.row, c.col, cols) }

  // Use single_source_distances from the Start Node
  // This essentially does a bounded BFS of our valid pipe loop
  let distances =
    pathfinding.single_source_distances(
      graph,
      start_node_id,
      0,
      fn(a, b) { a + b },
      int.compare,
    )

  // Furthest distance is max in the distances map
  dict.values(distances)
  |> list.fold(0, fn(acc, dist) { int.max(acc, dist) })
}

fn solve_part_2(grid_2d: List(List(Cell))) -> Int {
  let is_connected = fn(from_cell: Cell, to_cell: Cell) {
    can_connect(from_cell, to_cell)
  }

  let builder = grid.from_2d_list(grid_2d, model.Directed, is_connected)
  let graph = grid.to_graph(builder)
  let cols = list.length(result.unwrap(list.first(grid_2d), []))
  let rows = list.length(grid_2d)

  let start_node_id =
    list.flatten(grid_2d)
    |> list.find(fn(c) { c.char == "S" })
    |> result.unwrap(Cell(0, 0, "S"))
    |> fn(c) { grid.coord_to_id(c.row, c.col, cols) }

  let distances =
    pathfinding.single_source_distances(
      graph,
      start_node_id,
      0,
      fn(a, b) { a + b },
      int.compare,
    )

  let grid_dict =
    list.flatten(grid_2d)
    |> list.map(fn(c) { #(grid.coord_to_id(c.row, c.col, cols), c) })
    |> dict.from_list

  let assert Ok(s_cell) = dict.get(grid_dict, start_node_id)
  let up_id = grid.coord_to_id(s_cell.row - 1, s_cell.col, cols)
  let s_connects_up = case dict.get(grid_dict, up_id) {
    Ok(top) -> can_connect(s_cell, top) && dict.has_key(distances, up_id)
    _ -> False
  }

  list.fold(utils.int_range(0, rows - 1), 0, fn(acc, r) {
    let final_acc =
      list.fold(utils.int_range(0, cols - 1), #(acc, False), fn(inner, c) {
        let #(count, inside) = inner
        let id = grid.coord_to_id(r, c, cols)
        let in_loop = dict.has_key(distances, id)

        case in_loop {
          True -> {
            let assert Ok(cell) = dict.get(grid_dict, id)
            let flips = case cell.char {
              "|" | "L" | "J" -> True
              "S" -> s_connects_up
              _ -> False
            }

            case flips {
              True -> #(count, !inside)
              False -> #(count, inside)
            }
          }
          False -> {
            case inside {
              True -> #(count + 1, inside)
              False -> #(count, inside)
            }
          }
        }
      })
    final_acc.0
  })
}

/// The core logic mapping pipe combinations based on relative direction
fn can_connect(from: Cell, to: Cell) -> Bool {
  let row_diff = to.row - from.row
  let col_diff = to.col - from.col

  // Check valid directions out of 'from' towards 'to'
  let valid_out = case from.char {
    "|" -> row_diff != 0 && col_diff == 0
    "-" -> row_diff == 0 && col_diff != 0
    "L" -> #(row_diff, col_diff) == #(-1, 0) || #(row_diff, col_diff) == #(0, 1)
    "J" ->
      #(row_diff, col_diff) == #(-1, 0) || #(row_diff, col_diff) == #(0, -1)
    "7" -> #(row_diff, col_diff) == #(1, 0) || #(row_diff, col_diff) == #(0, -1)
    "F" -> #(row_diff, col_diff) == #(1, 0) || #(row_diff, col_diff) == #(0, 1)
    "S" -> True
    "." -> False
    _ -> False
  }

  // Check valid directions coming into 'to' from 'from'
  let valid_in = case to.char {
    "|" -> row_diff != 0 && col_diff == 0
    "-" -> row_diff == 0 && col_diff != 0
    "L" -> #(row_diff, col_diff) == #(1, 0) || #(row_diff, col_diff) == #(0, -1)
    "J" -> #(row_diff, col_diff) == #(1, 0) || #(row_diff, col_diff) == #(0, 1)
    "7" -> #(row_diff, col_diff) == #(-1, 0) || #(row_diff, col_diff) == #(0, 1)
    "F" ->
      #(row_diff, col_diff) == #(-1, 0) || #(row_diff, col_diff) == #(0, -1)
    "S" -> True
    "." -> False
    _ -> False
  }

  valid_out && valid_in
}

fn parse(raw_input: String) -> List(List(Cell)) {
  raw_input
  |> utils.to_lines()
  |> list.index_map(fn(line, row) {
    string.to_graphemes(line)
    |> list.index_map(fn(char, col) { Cell(row, col, char) })
  })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2023, 10)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo
  utils.exit(0)
}
