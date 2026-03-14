/// Title: The Ideal Stocking Stuffer
/// Link: https://adventofcode.com/2015/day/4
/// Difficulty: s
/// Tags: hash brute-force
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let secret = string.trim(raw_input)

  let part_1 = mine(secret, 1, FiveZeroes)
  let part_1_answer = part_1 |> OfInt

  let part_2 = mine(secret, part_1, SixZeroes) |> OfInt

  Solution(part_1_answer, part_2)
}

type Target {
  FiveZeroes
  SixZeroes
}

fn mine(secret: String, nonce: Int, target: Target) -> Int {
  let payload = <<secret:utf8, int.to_string(nonce):utf8>>
  let hash = utils.md5(payload)

  let is_match = case target {
    FiveZeroes ->
      case hash {
        <<0:size(8), 0:size(8), 0:size(4), _:bits>> -> True
        _ -> False
      }

    SixZeroes ->
      case hash {
        <<0:size(8), 0:size(8), 0:size(8), _:bits>> -> True
        _ -> False
      }
  }

  case is_match {
    True -> nonce
    False -> mine(secret, nonce + 1, target)
  }
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2015, 4) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
