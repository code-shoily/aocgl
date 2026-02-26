import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2019/day_06

const year = 2019

const day = 6

pub fn solve_test() {
  let expected = Solution(OfInt(147_807), OfInt(229))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_06.solve
  |> should.equal(expected)
}
