import common/solution.{type Solution, type SolutionError, NotDone}
import year_2019/day_01
import year_2019/day_06

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    6 -> day_06.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
