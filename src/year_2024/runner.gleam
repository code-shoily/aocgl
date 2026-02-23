import common/solution.{type Solution, type SolutionError, NotDone}
import year_2024/day_01

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
