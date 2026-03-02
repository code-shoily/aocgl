/// Title: Blizzard Basin
/// Link: https://adventofcode.com/2022/day/24
/// Difficulty: l
/// Tags: graph implicit-graph shortest-path bfs
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import yog/traversal

type State {
  State(x: Int, y: Int, t: Int)
}

fn has_blizzard(
  nx: Int,
  ny: Int,
  t: Int,
  up_set: Set(Int),
  down_set: Set(Int),
  left_set: Set(Int),
  right_set: Set(Int),
  inner_w: Int,
  inner_h: Int,
  total_w: Int,
) -> Bool {
  case nx <= 0 || nx > inner_w || ny <= 0 || ny > inner_h {
    True -> False
    False -> {
      let up_start_y =
        { int.modulo(ny - 1 + t, inner_h) |> result.unwrap(0) } + 1
      let down_start_y =
        { int.modulo(ny - 1 - t, inner_h) |> result.unwrap(0) } + 1
      let left_start_x =
        { int.modulo(nx - 1 + t, inner_w) |> result.unwrap(0) } + 1
      let right_start_x =
        { int.modulo(nx - 1 - t, inner_w) |> result.unwrap(0) } + 1

      let has_up = set.contains(up_set, up_start_y * total_w + nx)
      let has_down = set.contains(down_set, down_start_y * total_w + nx)
      let has_left = set.contains(left_set, ny * total_w + left_start_x)
      let has_right = set.contains(right_set, ny * total_w + right_start_x)

      has_up || has_down || has_left || has_right
    }
  }
}

fn bfs(
  start_x: Int,
  start_y: Int,
  start_t: Int,
  goal_x: Int,
  goal_y: Int,
  up_set: Set(Int),
  down_set: Set(Int),
  left_set: Set(Int),
  right_set: Set(Int),
  width: Int,
  height: Int,
  cycle_len: Int,
) -> Int {
  let inner_w = width - 2
  let inner_h = height - 2

  let is_valid = fn(nx: Int, ny: Int, t: Int) -> Bool {
    let is_start = nx == start_x && ny == start_y
    let is_goal = nx == goal_x && ny == goal_y

    let in_bounds = nx > 0 && nx <= inner_w && ny > 0 && ny <= inner_h

    case is_start || is_goal || in_bounds {
      False -> False
      True -> {
        !has_blizzard(
          nx,
          ny,
          t,
          up_set,
          down_set,
          left_set,
          right_set,
          inner_w,
          inner_h,
          width,
        )
      }
    }
  }

  let successors = fn(state: State) {
    let State(x, y, t) = state
    let nt = t + 1

    [#(x, y), #(x, y - 1), #(x, y + 1), #(x - 1, y), #(x + 1, y)]
    |> list.filter(fn(pos) { is_valid(pos.0, pos.1, nt) })
    |> list.map(fn(pos) { State(pos.0, pos.1, nt) })
  }

  let start_state = State(start_x, start_y, start_t)

  let get_key = fn(s: State) {
    let t_mod = s.t % cycle_len
    { { s.x * height + s.y } * cycle_len } + t_mod
  }

  let folder = fn(acc, s: State, _meta) {
    case s.x == goal_x && s.y == goal_y {
      True -> #(traversal.Halt, Some(s.t))
      False -> #(traversal.Continue, acc)
    }
  }

  let result =
    traversal.implicit_fold_by(
      from: start_state,
      using: traversal.BreadthFirst,
      initial: None,
      successors_of: successors,
      visited_by: get_key,
      with: folder,
    )

  case result {
    Some(time) -> time
    None -> -1
  }
}

pub fn solve(raw_input: String) -> Solution {
  let #(up_set, down_set, left_set, right_set, width, height) = parse(raw_input)

  let cycle_len = utils.lcm(width - 2, height - 2)

  let start_x = 1
  let start_y = 0
  let goal_x = width - 2
  let goal_y = height - 1

  let p1_time =
    bfs(
      start_x,
      start_y,
      0,
      goal_x,
      goal_y,
      up_set,
      down_set,
      left_set,
      right_set,
      width,
      height,
      cycle_len,
    )
  let part_1 = OfInt(p1_time)

  let p2_time_to_start =
    bfs(
      goal_x,
      goal_y,
      p1_time,
      start_x,
      start_y,
      up_set,
      down_set,
      left_set,
      right_set,
      width,
      height,
      cycle_len,
    )
  let p2_time_to_goal =
    bfs(
      start_x,
      start_y,
      p2_time_to_start,
      goal_x,
      goal_y,
      up_set,
      down_set,
      left_set,
      right_set,
      width,
      height,
      cycle_len,
    )
  let part_2 = OfInt(p2_time_to_goal)

  Solution(part_1, part_2)
}

fn parse(
  raw_input: String,
) -> #(Set(Int), Set(Int), Set(Int), Set(Int), Int, Int) {
  let lines = utils.to_lines(raw_input)
  let height = list.length(lines)
  let width = case list.first(lines) {
    Ok(line) -> string.length(line)
    Error(_) -> 0
  }

  let points =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes()
      |> list.index_map(fn(char, x) { #(y * width + x, char) })
    })
    |> list.flatten()

  let up_set =
    points
    |> list.filter(fn(p) { p.1 == "^" })
    |> list.map(fn(p) { p.0 })
    |> set.from_list()

  let down_set =
    points
    |> list.filter(fn(p) { p.1 == "v" })
    |> list.map(fn(p) { p.0 })
    |> set.from_list()

  let left_set =
    points
    |> list.filter(fn(p) { p.1 == "<" })
    |> list.map(fn(p) { p.0 })
    |> set.from_list()

  let right_set =
    points
    |> list.filter(fn(p) { p.1 == ">" })
    |> list.map(fn(p) { p.0 })
    |> set.from_list()

  #(up_set, down_set, left_set, right_set, width, height)
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2022, 24)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
