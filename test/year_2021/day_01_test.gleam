import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import year_2021/day_01

pub fn solve_test() {
  let param = InputParams(2021, 1)
  let assert Ok(input) = read_input(param)

  let got = day_01.solve(input)
  let expected = Solution(OfInt(1139), OfInt(1103))

  assert expected == got
}
