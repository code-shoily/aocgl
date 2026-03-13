import common/reader.{InputParams, read_input}
import common/solution.{OfInt, Solution}
import gleeunit/should
import year_2020/day_06

const year = 2020

const day = 6

pub fn solve_test() {
  let expected = Solution(OfInt(6885), OfInt(3550))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_06.solve
  |> should.equal(expected)
}

pub fn main() {
  solve_test()
}
