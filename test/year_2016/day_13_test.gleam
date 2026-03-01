import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2016/day_13

const year = 2016

const day = 13

pub fn solve_test() {
  let expected = Solution(OfInt(92), OfInt(124))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_13.solve
  |> should.equal(expected)
}
