import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2015/day_02

const year = 2015

const day = 2

pub fn solve_test() {
  let expected = Solution(OfInt(1_606_483), OfInt(3_842_356))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_02.solve
  |> should.equal(expected)
}
