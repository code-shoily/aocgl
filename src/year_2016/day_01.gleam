/// Title: 
/// Link: https://adventofcode.com/2016/day/1
/// Difficulty: s
/// Tags: fold navigation grid
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Instruction)) {
  input |> list.fold(new_pose(), step) |> fn(x) { x.at } |> manhattan()
}

fn solve_part_2(input: List(Instruction)) {
  input |> find_first_revisit() |> manhattan()
}

fn parse(raw_input: String) -> List(Instruction) {
  let assert Ok(navs) =
    raw_input
    |> string.split(on: ", ")
    |> list.map(new_instruction)
    |> result.all()

  navs
}

fn manhattan(coord: #(Int, Int)) -> Int {
  let #(x, y) = coord
  int.absolute_value(x) + int.absolute_value(y)
}

// ------------------------------------------ Pose Types
type Facing {
  North
  South
  East
  West
}

type Pose {
  Pose(at: #(Int, Int), facing: Facing)
}

fn new_pose() -> Pose {
  Pose(#(0, 0), North)
}

fn turn(pose: Pose, direction: Direction) -> Facing {
  case pose.facing, direction {
    North, Left -> West
    North, Right -> East
    South, Left -> East
    South, Right -> West
    East, Left -> North
    East, Right -> South
    West, Left -> South
    West, Right -> North
  }
}

fn step(pose: Pose, instruction: Instruction) -> Pose {
  let Instruction(direction, step) = instruction
  let facing = turn(pose, direction)
  let #(x, y) = pose.at

  let at = case facing {
    North -> #(x, y + step)
    South -> #(x, y - step)
    East -> #(x + step, y)
    West -> #(x - step, y)
  }

  Pose(at:, facing:)
}

fn collect_coords(pose: Pose, instruction: Instruction) -> List(#(Int, Int)) {
  let Instruction(direction, step) = instruction
  let facing = turn(pose, direction)

  int.range(0, step, [pose.at], fn(acc, _) {
    let assert [#(x, y), ..] = acc
    [
      case facing {
        North -> #(x, y + 1)
        South -> #(x, y - 1)
        East -> #(x + 1, y)
        West -> #(x - 1, y)
      },
      ..acc
    ]
  })
  |> list.reverse()
  |> list.drop(1)
}

type NavigationState {
  NavigationState(
    visits: set.Set(#(Int, Int)),
    pose: Pose,
    found: Option(#(Int, Int)),
  )
}

fn init_navigation() -> NavigationState {
  NavigationState(
    visits: set.from_list([#(0, 0)]),
    pose: new_pose(),
    found: None,
  )
}

fn find_first_revisit(instructions: List(Instruction)) -> #(Int, Int) {
  let NavigationState(_, _, found:) =
    instructions
    |> list.fold_until(init_navigation(), fn(acc_0, instruction) {
      let new_facing = turn(acc_0.pose, instruction.direction)
      collect_coords(acc_0.pose, instruction)
      |> list.fold(acc_0, fn(acc_1, x) {
        case set.contains(acc_1.visits, x) {
          True -> NavigationState(..acc_1, found: Some(x))
          False ->
            NavigationState(
              ..acc_1,
              pose: Pose(at: x, facing: new_facing),
              visits: acc_1.visits |> set.insert(x),
            )
        }
      })
      |> fn(navigation) {
        case option.is_some(navigation.found) {
          True -> Stop(navigation)
          False -> Continue(navigation)
        }
      }
    })

  let assert Some(point) = found

  point
}

// ------------------------------------------ Instruction Types

type Direction {
  Left
  Right
}

fn new_direction(s: String) -> Result(Direction, Nil) {
  case s {
    "L" -> Ok(Left)
    "R" -> Ok(Right)
    _ -> Error(Nil)
  }
}

type Instruction {
  Instruction(direction: Direction, steps: Int)
}

fn new_instruction(s: String) -> Result(Instruction, Nil) {
  use #(dir_char, dist_str) <- result.try(string.pop_grapheme(s))

  case new_direction(dir_char), int.parse(dist_str) {
    Ok(dir), Ok(dist) -> Ok(Instruction(dir, dist))
    _, _ -> Error(Nil)
  }
}

// ------------------------------------------ Runner
pub fn main() -> Nil {
  let param = reader.InputParams(2016, 1)
  let assert Ok(input) = reader.read_input(param)
  solve(input) |> echo

  Nil
}
