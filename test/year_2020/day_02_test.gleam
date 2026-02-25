import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2020/day_02

const year = 2020

const day = 2

pub fn solve_test() {
  let expected = Solution(OfInt(607), OfInt(321))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_02.solve
  |> should.equal(expected)
}
