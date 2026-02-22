import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2020/day_01

const year = 2020

const day = 1

pub fn solve_test() {
  let expected = Solution(OfInt(1_014_624), OfInt(80_072_256))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_01.solve
  |> should.equal(expected)
}
