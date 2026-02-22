import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2019/day_01

const year = 2019

const day = 1

pub fn solve_test() {
  let expected = Solution(OfInt(3_421_505), OfInt(5_129_386))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_01.solve
  |> should.equal(expected)
}
