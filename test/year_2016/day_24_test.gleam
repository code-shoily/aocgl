import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2016/day_24

const year = 2016

const day = 24

pub fn solve_test() {
  let expected = Solution(OfInt(462), OfInt(676))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_24.solve
  |> should.equal(expected)
}
