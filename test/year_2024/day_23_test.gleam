import common/reader.{InputParams, read_input}
import common/solution.{OfInt, OfStr, Solution}
import gleeunit/should
import year_2024/day_23

const year = 2024

const day = 23

pub fn solve_test() {
  let expected =
    Solution(OfInt(1330), OfStr("hl,io,ku,pk,ps,qq,sh,tx,ty,wq,xi,xj,yp"))

  InputParams(year, day)
  |> read_input
  |> should.be_ok
  |> day_23.solve
  |> should.equal(expected)
}
