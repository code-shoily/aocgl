import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2024/day_05

const year = 2024

const day = 5

pub fn solve_test() {
  let expected = Solution(OfInt(5391), OfInt(6142))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_05.solve
  |> should.equal(expected)
}
