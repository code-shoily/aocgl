import common/reader.{InputParams, read_input}
import common/solution.{OfNil, OfStr, Solution}
import gleeunit/should
import year_2018/day_07

const year = 2018

const day = 7

pub fn solve_test() {
  let expected = Solution(OfStr("BCADPVTJFZNRWXHEKSQLUYGMIO"), OfNil(Nil))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_07.solve
  |> should.equal(expected)
}
