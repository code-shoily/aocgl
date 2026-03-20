/// Title: Gift Shop
/// Link: https://adventofcode.com/2025/day/2
/// Difficulty: m
/// Tags: arithmetic
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = input |> total_invalid_ids_by(is_invalid_part_1) |> OfInt
  let part_2 = input |> total_invalid_ids_by(is_invalid_part_2) |> OfInt

  Solution(part_1, part_2)
}

fn total_invalid_ids_by(input: List(#(Int, Int)), check: fn(Int) -> Bool) -> Int {
  use acc, #(start, end) <- list.fold(input, 0)
  acc + sum_range(start, end, check, 0)
}

fn sum_range(current: Int, end: Int, check: fn(Int) -> Bool, acc: Int) -> Int {
  case current > end {
    True -> acc
    False -> {
      let next_acc = case check(current) {
        True -> acc + current
        False -> acc
      }
      sum_range(current + 1, end, check, next_acc)
    }
  }
}

fn parse(raw_input: String) -> List(#(Int, Int)) {
  raw_input
  |> string.trim
  |> string.split(",")
  |> list.map(parse_range)
}

fn is_invalid_part_1(n: Int) -> Bool {
  case bisect_number(n) {
    Some(#(a, b)) -> a == b
    None -> False
  }
}

fn is_invalid_part_2(n: Int) -> Bool {
  let len = utils.count_digits(n)

  let divisors =
    list.filter(utils.int_range(1, len / 2), fn(k) { len % k == 0 })

  use k <- list.any(divisors)
  let divisor = utils.int_pow(10, k)

  let unit = n % divisor
  check_repetition(n, unit, divisor)
}

fn check_repetition(n: Int, unit: Int, divisor: Int) -> Bool {
  case n {
    0 -> True
    _ if n % divisor == unit -> check_repetition(n / divisor, unit, divisor)
    _ -> False
  }
}

fn bisect_number(n: Int) {
  let digit_count = utils.count_digits(n)
  case int.is_odd(digit_count) {
    True -> None
    False -> {
      let divisor = utils.int_pow(10, digit_count / 2)
      let left = n / divisor
      let right = n % divisor

      Some(#(left, right))
    }
  }
}

fn parse_range(line: String) {
  let assert [left, right] = string.split(line, "-")
  let assert Ok(left_number) = int.parse(left)
  let assert Ok(right_number) = int.parse(right)

  #(left_number, right_number)
}

// ------------------------------ Exploration
import common/reader.{InputParams}

pub fn main() -> Nil {
  let assert Ok(input) = InputParams(2025, 2) |> reader.read_input
  input |> utils.timed(solve) |> echo

  utils.exit(0)
}
