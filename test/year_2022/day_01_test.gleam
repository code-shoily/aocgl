import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import year_2022/day_01

pub fn solve_test() {
  let param = InputParams(2022, 1)
  let assert Ok(input) = read_input(param)

  let got = day_01.solve(input)
  let expected = Solution(OfInt(70_720), OfInt(207_148))

  assert expected == got
}
