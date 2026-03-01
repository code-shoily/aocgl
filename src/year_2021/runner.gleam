import common/solution.{type Solution, type SolutionError, NotDone}
import year_2021/day_01
import year_2021/day_12
import year_2021/day_15

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    12 -> day_12.solve(raw_input) |> Ok
    15 -> day_15.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
