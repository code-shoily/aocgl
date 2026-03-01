/// Title: A Maze of Twisty Little Cubicles
/// Link: https://adventofcode.com/2016/day/13
/// Difficulty: m
/// Tags: graph bfs implicit-graph
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import yog/traversal.{BreadthFirst, Continue, Halt, Stop}

pub type Pos =
  #(Int, Int)

pub fn solve(raw_input: String) -> Solution {
  let fav = parse(raw_input)
  let part_1 = solve_part_1(fav) |> OfInt
  let part_2 = solve_part_2(fav) |> OfInt
  Solution(part_1, part_2)
}

fn solve_part_1(fav: Int) -> Int {
  let target = #(31, 39)
  traversal.implicit_fold(
    from: #(1, 1),
    using: BreadthFirst,
    initial: -1,
    successors_of: fn(pos) { open_neighbours(pos, fav) },
    with: fn(acc, pos, meta) {
      case pos == target {
        True -> #(Halt, meta.depth)
        False -> #(Continue, acc)
      }
    },
  )
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

// ── Maze helpers ─────────────────────────────────────────────────────────────

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
pub fn main() -> Nil {
  let param = reader.InputParams(2016, 13)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo
  utils.exit(0)
}
