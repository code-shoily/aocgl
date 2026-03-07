/// Title: Bridge Repair
/// Link: https://adventofcode.com/2024/day/7
/// Difficulty: m
/// Tags: tree
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let equations = parse(raw_input)

  let part_1 = solution_template(equations, [int.add, int.multiply]) |> OfInt
  let part_2 =
    solution_template(equations, [int.add, int.multiply, concatenate]) |> OfInt

  Solution(part_1, part_2)
}

fn solution_template(
  equations: List(Equation),
  fns: List(fn(Int, Int) -> Int),
) -> Int {
  use acc, eq <- list.fold(equations, 0)
  case can_solve(eq, fns) {
    True -> acc + eq.target
    False -> acc
  }
}

type Equation {
  Equation(target: Int, numbers: List(Int))
}

fn can_solve(equation: Equation, operators: List(fn(Int, Int) -> Int)) -> Bool {
  let assert [first, ..rest] = equation.numbers
  check_recursive(equation.target, first, rest, operators)
}

fn check_recursive(
  target: Int,
  current: Int,
  remaining: List(Int),
  operators: List(fn(Int, Int) -> Int),
) -> Bool {
  case current > target {
    True -> False
    False -> {
      case remaining {
        [] -> current == target
        [next, ..rest] -> {
          use op <- list.any(operators)
          check_recursive(target, op(current, next), rest, operators)
        }
      }
    }
  }
}

fn concatenate(a: Int, b: Int) -> Int {
  let assert Ok(res) = int.parse(int.to_string(a) <> int.to_string(b))
  res
}

fn parse(raw_input: String) -> List(Equation) {
  raw_input
  |> utils.to_lines()
  |> list.map(fn(line) {
    let assert Ok(#(target_str, nums_str)) = string.split_once(line, ": ")
    let assert Ok(target) = int.parse(target_str)
    let numbers =
      nums_str
      |> string.split(" ")
      |> list.map(fn(n) {
        let assert Ok(val) = int.parse(n)
        val
      })
    Equation(target, numbers)
  })
}
// -------------------------------- Explore
// import common/reader.{InputParams}

// pub fn main() {
//   let assert Ok(input) = InputParams(2024, 7) |> reader.read_input

//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
