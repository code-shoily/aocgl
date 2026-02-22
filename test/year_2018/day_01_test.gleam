import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2018/day_01

const year = 2018

const day = 1

pub fn solve_test() {
  let expected = Solution(OfInt(590), OfInt(83_445))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_01.solve
  |> should.equal(expected)
}
