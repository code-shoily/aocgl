import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2023/day_10

const year = 2023

const day = 10

pub fn solve_test() {
  let expected = Solution(OfInt(7107), OfInt(281))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_10.solve
  |> should.equal(expected)
}
