import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2023/day_17

const year = 2023

const day = 17

pub fn solve_test() {
  let expected = Solution(OfInt(1195), OfInt(1347))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_17.solve
  |> should.equal(expected)
}
