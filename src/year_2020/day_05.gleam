/// Title: Binary Boarding
/// Link: https://adventofcode.com/2020/day/5
/// Difficulty: xs
/// Tags: encode 
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  let assert Ok(max_id) = list.first(input)
  max_id
}

fn solve_part_2(input: List(Int)) -> Int {
  let assert Ok(#(larger, _smaller)) =
    input
    |> list.window_by_2
    |> list.find(fn(seats) { { pair.first(seats) - pair.second(seats) } > 1 })

  larger - 1
}

fn parse(raw_input: String) -> List(Int) {
  raw_input
  |> utils.to_lines()
  |> list.map(encode_seat)
  |> list.map(seat_id)
  |> list.sort(order.reverse(int.compare))
}

fn encode_seat(s: String) -> #(Int, Int) {
  let #(left, right) = #(string.slice(s, 0, 7), string.slice(s, 7, 3))
  #(encode(left), encode(right))
}

fn seat_id(seat: #(Int, Int)) -> Int {
  let #(row, col) = seat
  { row * 8 } + col
}

fn encode(s: String) -> Int {
  let str_encode =
    string.to_graphemes(s)
    |> list.map(fn(pos) {
      case pos {
        "R" | "B" -> "1"
        _ -> "0"
      }
    })
    |> string.join("")

  let assert Ok(value) = int.base_parse(str_encode, 2)

  value
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2020, 5) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
