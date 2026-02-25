import common/reader.{InputParams, read_input}
import common/solution.{OfStr, Solution}
import gleeunit/should
import year_2016/day_02

const year = 2016

const day = 2

pub fn solve_test() {
  let expected = Solution(OfStr("76792"), OfStr("A7AC3"))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_02.solve
  |> should.equal(expected)
}
