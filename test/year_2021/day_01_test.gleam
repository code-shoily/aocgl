import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2021/day_01

const year = 2021

const day = 1

pub fn solve_test() {
  let expected = Solution(OfInt(1139), OfInt(1103))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_01.solve
  |> should.equal(expected)
}
