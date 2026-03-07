/// Title: A Maze of Twisty Little Cubicles
/// Link: https://adventofcode.com/2016/day/13
/// Difficulty: m
/// Tags: graph bfs implicit-graph
import common/solution.{type Solution, OfInt, Solution}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/set
import gleam/string
import yog/pathfinding
import yog/traversal.{BreadthFirst, Continue, Stop}

pub fn solve(raw_input: String) -> Solution {
  let fav = parse(raw_input)
  let part_1 = solve_part_1(fav) |> OfInt
  let part_2 = solve_part_2(fav) |> OfInt
  Solution(part_1, part_2)
}

fn solve_part_1(fav: Int) -> Int {
  let target = #(31, 39)

  let assert Some(dist) =
    pathfinding.implicit_a_star(
      from: #(1, 1),
      is_goal: fn(pos) { pos == target },
      successors_with_cost: fn(pos) {
        open_neighbours(pos, fav) |> list.map(fn(n) { #(n, 1) })
      },
      heuristic: fn(pos) {
        int.absolute_value(pos.0 - target.0)
        + int.absolute_value(pos.1 - target.1)
      },
      with_zero: 0,
      with_add: int.add,
      with_compare: int.compare,
    )

  dist
}

fn solve_part_2(fav: Int) -> Int {
  traversal.implicit_fold(
    from: #(1, 1),
    using: BreadthFirst,
    initial: set.new(),
    successors_of: fn(pos) { open_neighbours(pos, fav) },
    with: fn(acc, pos, meta) {
      let new_acc = set.insert(acc, pos)
      case meta.depth >= 50 {
        True -> #(Stop, new_acc)
        False -> #(Continue, new_acc)
      }
    },
  )
  |> set.size()
}

type Pos =
  #(Int, Int)

fn is_wall(x: Int, y: Int, fav: Int) -> Bool {
  case x < 0 || y < 0 {
    True -> True
    False -> {
      let val = x * x + 3 * x + 2 * x * y + y + y * y + fav
      count_ones(val) % 2 != 0
    }
  }
}

fn open_neighbours(pos: Pos, fav: Int) -> List(Pos) {
  let #(x, y) = pos
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
  |> list.filter(fn(p) { !is_wall(p.0, p.1, fav) })
}

fn count_ones(n: Int) -> Int {
  do_count_ones(n, 0)
}

fn do_count_ones(n: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ ->
      do_count_ones(int.bitwise_shift_right(n, 1), acc + int.bitwise_and(n, 1))
  }
}

fn parse(raw_input: String) -> Int {
  raw_input
  |> string.trim()
  |> int.parse()
  |> result.unwrap(1350)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}
// import common/utils

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2016, 13) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
