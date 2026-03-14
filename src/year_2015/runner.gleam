import common/solution.{type Solution, type SolutionError, NotDone}
import year_2015/day_01
import year_2015/day_02
import year_2015/day_03
import year_2015/day_04

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    2 -> day_02.solve(raw_input) |> Ok
    3 -> day_03.solve(raw_input) |> Ok
    4 -> day_04.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
