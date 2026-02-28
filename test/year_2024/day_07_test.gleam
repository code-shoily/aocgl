import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2024/day_07

const year = 2024

const day = 7

pub fn solve_test() {
  let expected = Solution(OfInt(882_304_362_421), OfInt(145_149_066_755_184))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_07.solve
  |> should.equal(expected)
}
