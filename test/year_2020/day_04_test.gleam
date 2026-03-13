import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2020/day_04

const year = 2020

const day = 4

pub fn solve_test() {
  let expected = Solution(OfInt(233), OfInt(111))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_04.solve
  |> should.equal(expected)
}
