/// Title: Bridge Repair
/// Link: https://adventofcode.com/2024/day/7
/// Difficulty: m
/// Tags: graph equation
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Equation {
  Equation(target: Int, numbers: List(Int))
}

pub fn solve(raw_input: String) -> Solution {
  let equations = parse(raw_input)

  let part_1 = equations |> solve_part_1 |> OfInt
  let part_2 = equations |> solve_part_2 |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(equations: List(Equation)) -> Int {
  equations
  |> list.filter(fn(eq) { can_solve(eq, [int.add, int.multiply]) })
  |> list.map(fn(eq) { eq.target })
  |> int.sum
}

fn solve_part_2(equations: List(Equation)) -> Int {
  equations
  |> list.filter(fn(eq) { can_solve(eq, [int.add, int.multiply, concatenate]) })
  |> list.map(fn(eq) { eq.target })
  |> int.sum
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
          list.any(operators, fn(op) {
            check_recursive(target, op(current, next), rest, operators)
          })
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

pub fn main() -> Nil {
  let param = reader.InputParams(2024, 7)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo
  utils.exit(0)
}
