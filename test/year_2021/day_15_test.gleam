import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2021/day_15

const year = 2021

const day = 15

pub fn solve_test() {
  let expected = Solution(OfInt(583), OfInt(2927))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_15.solve
  |> should.equal(expected)
}
