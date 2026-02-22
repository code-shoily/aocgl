import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2022/day_01

const year = 2022

const day = 1

pub fn solve_test() {
  let expected = Solution(OfInt(70_720), OfInt(207_148))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_01.solve
  |> should.equal(expected)
}
