import common/solution.{type Solution, type SolutionError, NotDone}
import year_2023/day_01
import year_2023/day_10
import year_2023/day_25

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    10 -> day_10.solve(raw_input) |> Ok
    25 -> day_25.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
