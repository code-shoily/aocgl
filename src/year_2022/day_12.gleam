/// Title: Hill Climbing Algorithm
/// Link: https://adventofcode.com/2022/day/12
/// Difficulty: m
/// Tags: graph bfs shortest-path grid
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import yog/builder/grid
import yog/model
import yog/pathfinding
import yog/transform

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> Int {
  let Input(heightmap, start_id, end_id, _cols) = input

  let grid_result =
    grid.from_2d_list(heightmap, model.Directed, can_move: fn(from, to) {
      to - from <= 1
    })

  let graph = grid.to_graph(grid_result)

  case
    pathfinding.shortest_path(
      in: graph,
      from: start_id,
      to: end_id,
      with_zero: 0,
      with_add: int.add,
      with_compare: int.compare,
    )
  {
    option.Some(path) -> path.total_weight
    option.None -> 0
  }
}

fn solve_part_2(input: Input) -> Int {
  let Input(heightmap, _start_id, end_id, _cols) = input

  let grid_result =
    grid.from_2d_list(heightmap, model.Directed, can_move: fn(from, to) {
      to - from <= 1
    })

  let graph = grid.to_graph(grid_result)

  let reversed_graph = transform.transpose(graph)

  let distances =
    pathfinding.single_source_distances(
      in: reversed_graph,
      from: end_id,
      with_zero: 0,
      with_add: int.add,
      with_compare: int.compare,
    )

  grid_result.graph.nodes
  |> dict.to_list
  |> list.filter_map(fn(entry) {
    let #(node_id, elevation) = entry
    case elevation {
      0 -> dict.get(distances, node_id)
      _ -> Error(Nil)
    }
  })
  |> list.sort(int.compare)
  |> list.first
  |> result.unwrap(0)
}

type Input {
  Input(heightmap: List(List(Int)), start_id: Int, end_id: Int, cols: Int)
}

fn parse(raw_input: String) -> Input {
  let char_grid =
    raw_input
    |> utils.to_lines()
    |> list.map(string.to_graphemes)

  let rows = list.length(char_grid)
  let cols = case list.first(char_grid) {
    Ok(row) -> list.length(row)
    Error(_) -> 0
  }

  let #(start_row, start_col, end_row, end_col) =
    find_start_and_end(char_grid, rows, cols)

  let heightmap =
    char_grid
    |> list.map(fn(row) { list.map(row, char_to_elevation) })

  let start_id = start_row * cols + start_col
  let end_id = end_row * cols + end_col

  Input(heightmap, start_id, end_id, cols)
}

fn char_to_elevation(char: String) -> Int {
  case char {
    "S" -> 0
    "E" -> 25
    _ -> {
      case string.to_utf_codepoints(char) |> list.first {
        Ok(codepoint) -> string.utf_codepoint_to_int(codepoint) - 97
        Error(_) -> 0
      }
    }
  }
}

fn find_start_and_end(
  grid: List(List(String)),
  rows: Int,
  cols: Int,
) -> #(Int, Int, Int, Int) {
  let positions =
    utils.int_range(0, rows)
    |> list.flat_map(fn(row) {
      utils.int_range(0, cols)
      |> list.map(fn(col) { #(row, col) })
    })

  let assert Ok(#(start_row, start_col)) =
    positions
    |> list.find(fn(pos) { get_char_at(grid, pos.0, pos.1) == Ok("S") })

  let assert Ok(#(end_row, end_col)) =
    positions
    |> list.find(fn(pos) { get_char_at(grid, pos.0, pos.1) == Ok("E") })

  #(start_row, start_col, end_row, end_col)
}

fn get_char_at(
  grid: List(List(String)),
  row: Int,
  col: Int,
) -> Result(String, Nil) {
  use row_data <- result.try(grid |> list.drop(row) |> list.first)
  row_data |> list.drop(col) |> list.first
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2022, 12)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo
  echo utils.exit(0)
}
