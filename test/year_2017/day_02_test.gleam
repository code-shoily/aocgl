import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2017/day_02

const year = 2017

const day = 2

pub fn solve_test() {
  let expected = Solution(OfInt(32_020), OfInt(236))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_02.solve
  |> should.equal(expected)
}
