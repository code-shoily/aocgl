import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import year_2019/day_01

pub fn solve_test() {
  let param = InputParams(2019, 1)
  let assert Ok(input) = read_input(param)

  let got = day_01.solve(input)
  let expected = Solution(OfInt(3_421_505), OfInt(5_129_386))

  assert expected == got
}
