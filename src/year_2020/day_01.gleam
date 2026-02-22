/// Title: Report Repair (2020/1)
/// Link: https://adventofcode.com/2020/day/1
/// Difficulty: xs
/// Tags: n-sum
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/result

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  let assert Some(#(a, b)) = two_sum(input, 2020)

  a * b
}

fn solve_part_2(input: List(Int)) -> Int {
  let #(a, b, c) = three_sum(input, 2020)

  a * b * c
}

fn parse(raw_input: String) -> List(Int) {
  let assert Ok(ints) =
    raw_input
    |> utils.to_lines()
    |> utils.to_ints()

  list.sort(ints, by: int.compare)
}

fn two_sum(nums: List(Int), target: Int) -> Option(#(Int, Int)) {
  do_two_sum(nums, list.reverse(nums), target)
}

fn do_two_sum(xys: List(Int), yxs: List(Int), target: Int) {
  case xys, yxs {
    [x, ..xs], [y, ..ys] -> {
      case x + y {
        current_sum if current_sum > target -> do_two_sum(xys, ys, target)
        current_sum if current_sum < target -> do_two_sum(xs, yxs, target)
        _ -> Some(#(x, y))
      }
    }
    _, _ -> None
  }
}

type Acc {
  Acc(List(Int), Option(#(Int, Int, Int)))
}

fn three_sum(nums: List(Int), target: Int) -> #(Int, Int, Int) {
  let initial_state = Acc(nums, None)

  let assert Acc(_, Some(triplet)) =
    list.fold_until(nums, initial_state, fn(acc, _) {
      case acc {
        Acc([head, ..tail], _) -> {
          case two_sum(tail, target - head) {
            Some(#(a, b)) -> {
              let total = a + b + head
              case total == target {
                True -> Acc([], Some(#(a, b, head))) |> Stop
                False -> Acc(tail, None) |> Continue
              }
            }
            None -> Acc(tail, None) |> Continue
          }
        }
        _ -> panic as "This has no solution"
      }
    })

  triplet
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2020, 1)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> solution.print_solution

  Nil
}
