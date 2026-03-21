import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2017/day_04

const year = 2017

const day = 4

// If you want to run this test only
// gleam run -m year_2017/day_04
pub fn main() {
  solve_test()
}

pub fn solve_test() {
  let expected = Solution(OfInt(455), OfInt(186))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_04.solve
  |> should.equal(expected)
}
