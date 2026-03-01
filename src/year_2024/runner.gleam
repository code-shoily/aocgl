import common/solution.{type Solution, type SolutionError, NotDone}
import year_2024/day_01
import year_2024/day_05
import year_2024/day_07
import year_2024/day_18
import year_2024/day_23

pub fn solve_for(raw_input: String, day: Int) -> Result(Solution, SolutionError) {
  case day {
    1 -> day_01.solve(raw_input) |> Ok
    5 -> day_05.solve(raw_input) |> Ok
    7 -> day_07.solve(raw_input) |> Ok
    18 -> day_18.solve(raw_input) |> Ok
    23 -> day_23.solve(raw_input) |> Ok
    _ -> Error(NotDone)
  }
}
