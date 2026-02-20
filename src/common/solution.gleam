import gleam/float
import gleam/int
import gleam/io

pub type Value {
  Int(Int)
  Float(Float)
  Str(String)
}

pub type Solution {
  Solution(part1: Value, part2: Value)
}

pub type SolutionError {
  NotDone
  InvalidYear
}

fn value_to_string(value: Value) -> String {
  case value {
    Int(value) -> int.to_string(value)
    Float(value) -> float.to_string(value)
    Str(value) -> value
  }
}

pub fn print_solution(solution: Solution) {
  io.println(
    value_to_string(solution.part1) <> "\t" <> value_to_string(solution.part2),
  )
}
