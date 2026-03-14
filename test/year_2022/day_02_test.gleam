import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2022/day_02

const year = 2022

const day = 2

// If you want to run this test only
// gleam run -m year_2022/day_02
pub fn main() {
  solve_test()
}

pub fn solve_test() {
  let expected = Solution(OfInt(12_645), OfInt(11_756))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_02.solve
  |> should.equal(expected)
}
