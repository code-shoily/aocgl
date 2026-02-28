import common/reader.{InputParams, read_input}
import common/solution.{OfDay25, OfInt, Solution}
import gleeunit/should
import year_2023/day_25

const year = 2023

const day = 25

pub fn solve_test() {
  let expected = Solution(OfInt(558_376), OfDay25(Nil))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_25.solve
  |> should.equal(expected)
}
