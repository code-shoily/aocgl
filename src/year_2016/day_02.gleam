/// Title: Bathroom Security
/// Link: https://adventofcode.com/2016/day/2
/// Difficulty: s
/// Tags: grid
import common/reader
import common/solution.{type Solution, OfStr, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

const grid_1 = [
  ["1", "2", "3"],
  ["4", "5", "6"],
  ["7", "8", "9"],
]

const grid_2 = [
  ["_", "_", "1", "_", "_"],
  [
    "_",
    "2",
    "3",
    "4",
    "_",
  ],
  ["5", "6", "7", "8", "9"],
  [
    "_",
    "A",
    "B",
    "C",
    "_",
  ],
  ["_", "_", "D", "_", "_"],
]

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfStr
  let part_2 = solve_part_2(input) |> OfStr

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(List(Direction))) -> String {
  grid_1 |> to_numpad |> solution_template(input, #(1, 1))
}

fn solve_part_2(input: List(List(Direction))) -> String {
  grid_2 |> to_numpad |> solution_template(input, #(0, 2))
}

fn solution_template(
  numpad: Numpad,
  input: List(List(Direction)),
  start: Pos,
) -> String {
  let assert Ok(chars) =
    input
    |> list.map(fn(x) { key_position(x, start, numpad) |> dict.get(numpad, _) })
    |> result.all

  chars |> string.join("")
}

fn parse(raw_input: String) -> List(List(Direction)) {
  raw_input
  |> utils.to_lines()
  |> list.map(fn(line) { line |> string.to_graphemes |> list.map(direction) })
}

type Numpad =
  Dict(Pos, String)

type Pos =
  #(Int, Int)

type Direction {
  Up
  Down
  Left
  Right
}

fn direction(d: String) -> Direction {
  case d {
    "U" -> Up
    "D" -> Down
    "L" -> Left
    "R" -> Right
    _ -> panic as "Wrong Input"
  }
}

fn to_numpad(input: List(List(String))) -> Numpad {
  input
  |> utils.to_dict_grid()
  |> dict.filter(fn(_, value) { value != "_" })
}

fn next_position(direction: Direction, pos: Pos, numpad: Numpad) -> Pos {
  let #(x, y) = pos
  let updated_position = case direction {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
  }

  case dict.has_key(numpad, updated_position) {
    True -> updated_position
    False -> pos
  }
}

fn key_position(
  directions: List(Direction),
  current_position: Pos,
  numpad: Numpad,
) -> Pos {
  list.fold(directions, current_position, fn(pos, dir) {
    next_position(dir, pos, numpad)
  })
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2016, 2)
  let input = reader.read_input(param) |> result.unwrap(or: "")

  solve(input) |> echo

  utils.exit(0)
}
