/// Title: Pipe Maze
/// Link: https://adventofcode.com/2023/day/10
/// Difficulty: xl
/// Tags: graph bfs grid
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import yog/builder/grid
import yog/model
import yog/pathfinding/dijkstra as pathfinding

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(grid_2d: List(List(Cell))) -> Int {
  let graph =
    grid.from_2d_list(grid_2d, model.Directed, can_connect) |> grid.to_graph
  let cols = list.first(grid_2d) |> result.unwrap([]) |> list.length

  let from_node =
    list.flatten(grid_2d)
    |> list.find(fn(c) { c.char == "S" })
    |> result.unwrap(Cell(0, 0, "S"))
    |> fn(c) { grid.coord_to_id(c.row, c.col, cols) }

  pathfinding.single_source_distances(graph, from_node, 0, int.add, int.compare)
  |> dict.values
  |> list.fold(0, int.max)
}

fn solve_part_2(grid_2d: List(List(Cell))) -> Int {
  let builder = grid.from_2d_list(grid_2d, model.Directed, can_connect)
  let graph = grid.to_graph(builder)
  let cols = list.length(result.unwrap(list.first(grid_2d), []))
  let rows = list.length(grid_2d)

  let from_id =
    list.flatten(grid_2d)
    |> list.find(fn(c) { c.char == "S" })
    |> result.unwrap(Cell(0, 0, "S"))
    |> fn(c) { grid.coord_to_id(c.row, c.col, cols) }

  let distances =
    pathfinding.single_source_distances(graph, from_id, 0, int.add, int.compare)

  let grid_dict =
    list.flatten(grid_2d)
    |> list.map(fn(c) { #(grid.coord_to_id(c.row, c.col, cols), c) })
    |> dict.from_list

  let assert Ok(s_cell) = dict.get(grid_dict, from_id)
  let up_id = grid.coord_to_id(s_cell.row - 1, s_cell.col, cols)
  let s_connects_up = case dict.get(grid_dict, up_id) {
    Ok(top) -> can_connect(s_cell, top) && dict.has_key(distances, up_id)
    _ -> False
  }

  let lines = utils.int_range(0, rows - 1)
  use acc, r <- list.fold(lines, 0)

  let final_acc = {
    let cells = utils.int_range(0, cols - 1)
    use #(count, inside), c <- list.fold(cells, #(acc, False))

    let id = grid.coord_to_id(r, c, cols)

    case dict.has_key(distances, id) {
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
  }

  final_acc.0
}

type Cell {
  Cell(row: Int, col: Int, char: String)
}

fn can_connect(from: Cell, to: Cell) -> Bool {
  let row_diff = to.row - from.row
  let col_diff = to.col - from.col

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
  let lines = utils.to_lines(raw_input)
  use line, row <- list.index_map(lines)

  let chars = string.to_graphemes(line)
  use char, col <- list.index_map(chars)

  Cell(row, col, char)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() {
//   let assert Ok(input) = InputParams(2023, 10) |> reader.read_input

//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
