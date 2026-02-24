/// Title: Secret Entrance
/// Link: https://adventofcode.com/2025/day/1
/// Difficulty: m
/// Tags: modular-algebra rotation security
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let #(_, part_1, part_2) =
    raw_input
    |> parse()
    |> list.fold(#(50, 0, 0), fn(acc, move) {
      let #(current, password_1, password_2) = acc
      let #(next, zeroes) = rotate(move, current)

      let password_1 = case next == 0 {
        True -> password_1 + 1
        False -> password_1
      }
      let password_2 = password_2 + zeroes

      #(next, password_1, password_2)
    })

  Solution(OfInt(part_1), OfInt(part_2))
}

fn parse(raw_input: String) -> List(Rotation) {
  raw_input
  |> utils.to_lines()
  |> list.map(parse_rotation)
}

type Rotation {
  Rotation(towards: fn(Int, Int) -> Int, times: Int)
}

fn new_rotation(dir: String, times: String) -> Rotation {
  case dir, int.parse(times) {
    "L", Ok(x) -> Rotation(int.subtract, x)
    "R", Ok(x) -> Rotation(int.add, x)
    _, _ -> panic as "Impossible State"
  }
}

fn parse_rotation(line: String) -> Rotation {
  let assert Ok(#(x, xs)) = string.pop_grapheme(line)
  new_rotation(x, xs)
}

fn rotate(rotation: Rotation, current: Int) -> #(Int, Int) {
  let diff = current |> rotation.towards(rotation.times % 100)
  let zeroes = rotation.times / 100

  case diff {
    diff if diff < 0 && current == 0 -> #(diff + 100, zeroes)
    diff if diff < 0 -> #(diff + 100, zeroes + 1)
    diff if diff >= 100 -> #(diff - 100, zeroes + 1)
    diff if diff == 0 -> #(0, zeroes + 1)
    _ -> #(diff, zeroes)
  }
}

// ------------------------------ Exploration
pub fn main() {
  let param = reader.InputParams(2025, 1)
  let assert Ok(input) = reader.read_input(param)

  echo solve(input)

  utils.exit(0)
}
