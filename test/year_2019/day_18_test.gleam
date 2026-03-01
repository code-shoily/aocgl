import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2019/day_18

const year = 2019

const day = 18

pub fn solve_test() {
  let expected = Solution(OfInt(6098), OfInt(1698))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_18.solve
  |> should.equal(expected)
}
