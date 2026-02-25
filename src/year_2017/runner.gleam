import common/solution.{type Solution, type SolutionError, NotDone}
import year_2017/day_01
import year_2017/day_02

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    2 -> day_02.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
