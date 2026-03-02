/// Title: Clumsy Crucible
/// Link: https://adventofcode.com/2023/day/17
/// Difficulty: xl
/// Tags: graph implicit-graph shortest-path
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import yog/pathfinding

pub type Direction {
  Up
  Down
  Left
  Right
}

pub type State {
  State(x: Int, y: Int, dir: Direction, count: Int)
}

fn dir_to_int(dir: Direction) -> Int {
  case dir {
    Up -> 0
    Down -> 1
    Left -> 2
    Right -> 3
  }
}

fn turn_left(dir: Direction) -> Direction {
  case dir {
    Up -> Left
    Down -> Right
    Left -> Down
    Right -> Up
  }
}

fn turn_right(dir: Direction) -> Direction {
  case dir {
    Up -> Right
    Down -> Left
    Left -> Up
    Right -> Down
  }
}

fn move(x: Int, y: Int, dir: Direction) -> #(Int, Int) {
  case dir {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
  }
}

pub fn solve(raw_input: String) -> Solution {
  let #(grid, width, height) = parse(raw_input)

  let part1 = solve_with_rules(grid, width, height, 1, 3) |> OfInt
  let part2 = solve_with_rules(grid, width, height, 4, 10) |> OfInt

  Solution(part1, part2)
}

fn get_neighbors(
  state: State,
  grid: Dict(Int, Int),
  width: Int,
  height: Int,
  min_s: Int,
  max_s: Int,
) -> List(#(State, Int)) {
  let mut_neighbors = []

  let is_valid = fn(nx, ny) { nx >= 0 && nx < width && ny >= 0 && ny < height }

  // 1. Straight
  let mut_neighbors = case state.count < max_s {
    True -> {
      let #(nx, ny) = move(state.x, state.y, state.dir)
      case is_valid(nx, ny) {
        True -> {
          let assert Ok(w) = dict.get(grid, ny * width + nx)
          [#(State(nx, ny, state.dir, state.count + 1), w), ..mut_neighbors]
        }
        False -> mut_neighbors
      }
    }
    False -> mut_neighbors
  }

  case state.count >= min_s || state.count == 0 {
    True -> {
      let l_dir = turn_left(state.dir)
      let #(lx, ly) = move(state.x, state.y, l_dir)
      let mut_neighbors = case is_valid(lx, ly) {
        True -> {
          let assert Ok(w) = dict.get(grid, ly * width + lx)
          [#(State(lx, ly, l_dir, 1), w), ..mut_neighbors]
        }
        False -> mut_neighbors
      }

      let r_dir = turn_right(state.dir)
      let #(rx, ry) = move(state.x, state.y, r_dir)
      case is_valid(rx, ry) {
        True -> {
          let assert Ok(w) = dict.get(grid, ry * width + rx)
          [#(State(rx, ry, r_dir, 1), w), ..mut_neighbors]
        }
        False -> mut_neighbors
      }
    }
    False -> mut_neighbors
  }
}

fn solve_with_rules(
  grid: Dict(Int, Int),
  width: Int,
  height: Int,
  min_s: Int,
  max_s: Int,
) -> Int {
  let start = State(0, 0, Right, 0)

  let successors = fn(state) {
    get_neighbors(state, grid, width, height, min_s, max_s)
  }
  let is_goal = fn(state: State) {
    state.x == width - 1 && state.y == height - 1 && state.count >= min_s
  }

  // Use implicit_dijkstra_by to pack the state into an integer key for faster map lookups
  // Key packing: ((x * height + y) * 4 + dir_int) * 11 + count
  let get_key = fn(state: State) {
    let dir_int = dir_to_int(state.dir)
    { { state.x * height + state.y } * 4 + dir_int } * 11 + state.count
  }

  let result =
    pathfinding.implicit_dijkstra_by(
      from: start,
      visited_by: get_key,
      successors_with_cost: successors,
      is_goal: is_goal,
      with_zero: 0,
      with_add: int.add,
      with_compare: int.compare,
    )

  case result {
    Some(dist) -> dist
    None -> -1
  }
}

fn parse(raw_input: String) -> #(Dict(Int, Int), Int, Int) {
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
      |> list.index_map(fn(char, x) {
        let assert Ok(val) = int.parse(char)
        #(y * width + x, val)
      })
    })
    |> list.flatten()
    |> dict.from_list()

  #(grid, width, height)
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2023, 17)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
