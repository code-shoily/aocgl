import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2021/day_12

const year = 2021

const day = 12

pub fn solve_test() {
  let expected = Solution(OfInt(4659), OfInt(148_962))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_12.solve
  |> should.equal(expected)
}
