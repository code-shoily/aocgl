import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2015/day_05

const year = 2015

const day = 5

// If you want to run this test only
// gleam run -m year_2015/day_05
pub fn main() {
  solve_test()
}

pub fn solve_test() {
  let expected = Solution(OfInt(255), OfInt(55))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_05.solve
  |> should.equal(expected)
}
