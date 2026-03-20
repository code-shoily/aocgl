import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2025/day_02

const year = 2025

const day = 2

// If you want to run this test only
// gleam run -m year_2025/day_02
pub fn main() {
  solve_test()
}

pub fn solve_test() {
  let expected = Solution(OfInt(44_854_383_294), OfInt(55_647_141_923))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_02.solve
  |> should.equal(expected)
}
