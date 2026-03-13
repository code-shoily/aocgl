import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2020/day_03

const year = 2020

const day = 3

pub fn solve_test() {
  let expected = Solution(OfInt(272), OfInt(3_898_725_600))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_03.solve
  |> should.equal(expected)
}
