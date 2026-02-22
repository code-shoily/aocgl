/// Title: 
/// Link: https://adventofcode.com/2019/day/1
/// Difficulty: 
/// Tags: 
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/result

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  input |> list.map(find_fuel_1) |> int.sum()
}

fn solve_part_2(input: List(Int)) -> Int {
  int.sum({
    use mass <- list.map(input)
    list_fuels(mass, []) |> int.sum()
  })
}

fn parse(raw_input: String) -> List(Int) {
  let assert Ok(nums) = raw_input |> utils.to_lines() |> utils.to_ints()
  nums
}

fn find_fuel_1(mass: Int) -> Int {
  case int.divide(mass, 3) {
    Ok(n) -> n - 2
    _ -> 0
  }
}

fn list_fuels(mass: Int, total_fuel: List(Int)) -> List(Int) {
  case find_fuel_1(mass) {
    n if n <= 0 -> total_fuel
    n -> list_fuels(n, [n, ..total_fuel])
  }
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2019, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  Nil
}
