import common/solution.{type Solution, type SolutionError, NotDone}
import year_2016/day_01
import year_2016/day_02
import year_2016/day_13
import year_2016/day_24

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    2 -> day_02.solve(raw_input) |> Ok
    13 -> day_13.solve(raw_input) |> Ok
    24 -> day_24.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
