import gleam/float
import gleam/int
import gleam/io

pub type Value {
  OfInt(Int)
  OfFloat(Float)
  OfStr(String)
  OfNil(Nil)
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
    OfInt(value) -> int.to_string(value)
    OfFloat(value) -> float.to_string(value)
    OfStr(value) -> value
    OfNil(_) -> "<Nil>"
  }
}

pub fn print_solution(solution: Solution) {
  io.println(
    value_to_string(solution.part1) <> "\t" <> value_to_string(solution.part2),
  )
}
