import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2017/day_01

const year = 2017

const day = 1

pub fn solve_test() {
  let expected = Solution(OfInt(1089), OfInt(1156))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_01.solve
  |> should.equal(expected)
}
