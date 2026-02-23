import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2024/day_01

const year = 2024

const day = 1

pub fn solve_test() {
  let expected = Solution(OfInt(2_742_123), OfInt(21_328_497))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_01.solve
  |> should.equal(expected)
}
