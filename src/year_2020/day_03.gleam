/// Title: Toboggan Trajectory
/// Link: https://adventofcode.com/2020/day/3
/// Difficulty: xs
/// Tags: graph implicit-graph over-engineered
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import yog/traversal

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)

  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: Terrain) -> Int {
  count_trees(input, 3, 1)
}

fn solve_part_2(input: Terrain) -> Int {
  let slopes = [#(1, 1), #(3, 1), #(5, 1), #(7, 1), #(1, 2)]

  use acc, #(dx, dy) <- list.fold(slopes, 1)
  acc * count_trees(input, dx, dy)
}

fn count_trees(input: Terrain, slope_x: Int, slope_y: Int) -> Int {
  let #(grid, width, height) = input

  traversal.implicit_fold(
    from: #(0, 0),
    using: traversal.DepthFirst,
    initial: 0,
    successors_of: fn(pos) {
      let #(x, y) = pos
      let next_x = { x + slope_x } % width
      let next_y = y + slope_y

      case next_y >= height {
        True -> []
        False -> [#(next_x, next_y)]
      }
    },
    with: fn(acc, pos, _meta) {
      let is_tree = result.unwrap(dict.get(grid, pos), "") == "#"
      let new_acc = case is_tree {
        True -> acc + 1
        False -> acc
      }
      #(traversal.Continue, new_acc)
    },
  )
}

type Terrain =
  #(Dict(#(Int, Int), String), Int, Int)

fn parse(raw_input: String) -> Terrain {
  let assert [h, ..] as lines = raw_input |> utils.to_lines()
  let height = list.length(lines)
  let width = list.length(string.to_graphemes(h))
  let grid =
    lines
    |> list.map(string.to_graphemes)
    |> utils.to_dict_grid

  #(grid, width, height)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}
// import common/utils

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2020, 3) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
