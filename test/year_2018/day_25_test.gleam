import common/reader.{InputParams, read_input}
import common/solution.{OfInt, OfNil, Solution}
import gleeunit/should
import year_2018/day_25

const year = 2018

const day = 25

pub fn solve_test() {
  let expected = Solution(OfInt(346), OfNil(Nil))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_25.solve
  |> should.equal(expected)
}
