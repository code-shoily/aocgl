import common/reader
import common/solution.{OfInt, Solution}
import gleam/result
import year_2016/day_01

pub fn solve_test() {
  let param = reader.InputParams(2016, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  let result = day_01.solve(input)

  assert result == Solution(OfInt(253), OfInt(126))
}
