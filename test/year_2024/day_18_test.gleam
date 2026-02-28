import common/reader.{InputParams, read_input}
import common/solution.{OfInt, OfStr, Solution}
import gleeunit/should
import year_2024/day_18

const year = 2024

const day = 18

pub fn solve_test() {
  let expected = Solution(OfInt(226), OfStr("60,46"))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_18.solve
  |> should.equal(expected)
}
