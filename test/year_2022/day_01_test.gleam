import common/reader.{InputParams, read_input}
import common/solution.{Solution, OfInt}
import year_2022/day_01

pub fn solve_test() {
  let param = InputParams(2022, 1)
  let assert Ok(input) = read_input(param)

  let got = day_01.solve(input)
  let expected = Solution(OfInt(5), OfInt(10))

  assert expected == got
}