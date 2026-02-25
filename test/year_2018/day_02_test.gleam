import common/reader.{InputParams, read_input}
import common/solution.{OfInt, OfStr, Solution}
import gleeunit/should
import year_2018/day_02

const year = 2018

const day = 2

pub fn solve_test() {
  let expected = Solution(OfInt(7221), OfStr("mkcdflathzwsvjxrevymbdpoq"))
  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_02.solve
  |> should.equal(expected)
}
