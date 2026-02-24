/// Title: Secret Entrance
/// Link: https://adventofcode.com/2025/day/1
/// Difficulty: m
/// Tags: modular-algebra rotation security
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
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
  Rotation(towards: fn(Int, Int) -> Int, reps: Int)
}

fn new_rotation(dir: String, reps: String) -> Rotation {
  case dir, int.parse(reps) {
    "L", Ok(x) -> Rotation(int.subtract, x)
    "R", Ok(x) -> Rotation(int.add, x)
    _, _ -> panic as "Impossible State"
  }
}

fn parse_rotation(line: String) -> Rotation {
  let assert Ok(#(x, xs)) = string.pop_grapheme(line)
  new_rotation(x, xs)
}

fn rotate(rotation: Rotation, by: Int) -> #(Int, Int) {
  let diff = rotation.towards(by, rotation.reps % 100)
  let zeroes = rotation.reps / 100

  case diff, by {
    diff, 0 if diff < 0 -> #(diff + 100, zeroes)
    diff, _ if diff < 0 -> #(diff + 100, zeroes + 1)
    diff, _ if diff >= 100 -> #(diff - 100, zeroes + 1)
    diff, _ if diff == 0 -> #(0, zeroes + 1)
    _, _ -> #(diff, zeroes)
  }
}

// ------------------------------ Exploration
pub fn main() {
  let param = reader.InputParams(2025, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")

  echo solve(input)

  utils.exit(0)
}
