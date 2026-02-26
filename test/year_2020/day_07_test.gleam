import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2020/day_07

const year = 2020

const day = 7

pub fn solve_test() {
  let expected = Solution(OfInt(355), OfInt(5312))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_07.solve
  |> should.equal(expected)
}
