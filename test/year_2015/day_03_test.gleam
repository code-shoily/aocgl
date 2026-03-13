import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2015/day_03

const year = 2015

const day = 3

// If you want to run this test only
// gleam run -m year_2015/day_03
pub fn main() {
  solve_test()
}

pub fn solve_test() {
  let expected = Solution(OfInt(2081), OfInt(2341))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_03.solve
  |> should.equal(expected)
}
