import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import year_2018/day_01

pub fn solve_test() {
  let param = InputParams(2018, 1)
  let assert Ok(input) = read_input(param)

  let got = day_01.solve(input)
  let expected = Solution(OfInt(590), OfInt(83_445))

  assert expected == got
}
