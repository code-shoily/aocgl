/// Title: Perfectly Spherical Houses in a Vacuum
/// Link: https://adventofcode.com/2015/day/3
/// Difficulty: xs
/// Tags: set
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/list
import gleam/set
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Direction)) -> Int {
  houses_visited(input) |> set.size()
}

fn solve_part_2(input: List(Direction)) -> Int {
  let #(santa, robo) = distribute_tasks(input, #([], []))

  houses_visited(santa)
  |> set.union(houses_visited(robo))
  |> set.size
}

fn parse(raw_input: String) -> List(Direction) {
  raw_input
  |> string.trim()
  |> to_directions
}

type Direction {
  Up
  Down
  Left
  Right
}

fn new_direction(ch: String) -> Direction {
  case ch {
    "^" -> Up
    "v" -> Down
    "<" -> Left
    ">" -> Right
    _ -> panic as "Parse Error"
  }
}

fn to_directions(line: String) -> List(Direction) {
  line
  |> string.to_graphemes
  |> list.map(new_direction)
}

fn distribute_tasks(
  directions: List(Direction),
  distribution: #(List(Direction), List(Direction)),
) {
  let #(of_santa, of_robo) = distribution
  case directions {
    [santa, robo, ..rest] ->
      rest |> distribute_tasks(#([santa, ..of_santa], [robo, ..of_robo]))
    [santa] -> #([santa, ..of_santa], of_robo) |> rewind()
    _ -> distribution |> rewind()
  }
}

fn rewind(workers: #(List(a), List(a))) -> #(List(a), List(a)) {
  #(list.reverse(workers.0), list.reverse(workers.1))
}

fn houses_visited(directions: List(Direction)) {
  let initial_state = #(set.from_list([#(0, 0)]), #(0, 0))

  let #(final_visited, _) = {
    use state, direction <- list.fold(directions, initial_state)
    let #(visited, #(x, y)) = state

    let next_pos = case direction {
      Up -> #(x, y + 1)
      Down -> #(x, y - 1)
      Left -> #(x - 1, y)
      Right -> #(x + 1, y)
    }

    #(set.insert(visited, next_pos), next_pos)
  }

  final_visited
}

// ------------------------------ Exploration
import common/reader.{InputParams}

pub fn main() -> Nil {
  let assert Ok(input) = InputParams(2015, 3) |> reader.read_input

  input |> utils.timed(solve) |> echo

  utils.exit(0)
}
