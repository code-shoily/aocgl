import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2022/day_16

const year = 2022

const day = 16

pub fn solve_test() {
  let expected = Solution(OfInt(1673), OfInt(2343))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_16.solve
  |> should.equal(expected)
}
