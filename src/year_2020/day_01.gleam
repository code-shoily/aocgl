/// Title: Report Repair (2020/1)
/// Link: https://adventofcode.com/2020/day/1
/// Difficulty: xs
/// Tags: n-sum
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}

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

fn three_sum(nums: List(Int), target: Int) -> #(Int, Int, Int) {
  let initial_state = #(nums, None)

  let assert #(_, Some(triplet)) = {
    use sum_acc_state, _ <- list.fold_until(nums, initial_state)

    let assert #([head, ..tail], _) = sum_acc_state

    case two_sum(tail, target - head) {
      Some(#(a, b)) -> {
        case a + b + head {
          sum if sum == target -> Stop(#([], Some(#(a, b, head))))
          _ -> Continue(#(tail, None))
        }
      }
      None -> Continue(#(tail, None))
    }
  }

  triplet
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() {
//   let assert Ok(input) = InputParams(2020, 1) |> reader.read_input
//   input |> utils.timed(solve) |> echo
// }
