/// Title: I Was Told There Would Be No Math
/// Link: https://adventofcode.com/2015/day/2
/// Difficulty: xs
/// Tags: geometry measurement
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Present)) -> Int {
  input |> solution_template(smallest_side_area, surface_area)
}

fn solve_part_2(input: List(Present)) -> Int {
  input |> solution_template(smallest_perimeter, volume)
}

type PresentFunc =
  fn(Present) -> Int

fn solution_template(
  input: List(Present),
  fn_1: PresentFunc,
  fn_2: PresentFunc,
) -> Int {
  input
  |> list.map(fn(p) { fn_1(p) + fn_2(p) })
  |> int.sum
}

fn parse(raw_input: String) -> List(Present) {
  raw_input
  |> utils.to_lines()
  |> list.map(new_present)
}

type Present {
  Present(l: Int, w: Int, h: Int)
}

fn new_present(line: String) -> Present {
  let assert Ok([l, w, h]) =
    string.split(line, "x")
    |> list.map(int.parse)
    |> result.all

  Present(l:, w:, h:)
}

fn smallest_sides(present: Present) -> #(Int, Int) {
  let Present(l, w, h) = present
  let assert [left, right] = [l, w, h] |> list.sort(int.compare) |> list.take(2)
  #(left, right)
}

fn smallest_side_area(present: Present) -> Int {
  let #(left, right) = smallest_sides(present)
  left * right
}

fn smallest_perimeter(present: Present) -> Int {
  let #(left, right) = smallest_sides(present)
  2 * { left + right }
}

fn surface_area(present: Present) -> Int {
  let Present(l, w, h) = present
  2 * { l * w + w * h + h * l }
}

fn volume(present: Present) -> Int {
  let Present(l, w, h) = present
  l * w * h
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2015, 2)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
