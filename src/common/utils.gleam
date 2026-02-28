import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Splits a string into lines. Damn you CRLF.
pub fn to_lines(input: String) -> List(String) {
  input
  |> string.replace(each: "\r\n", with: "\n")
  |> string.trim()
  |> string.split(on: "\n")
}

/// Converts a list of strings to a list of numbers.
pub fn to_ints(input: List(String)) -> Result(List(Int), Nil) {
  input
  |> list.map(int.parse)
  |> result.all()
}

/// Converts a string into sections based on \n\n
pub fn to_paragraphs(input: String) -> List(String) {
  input
  |> string.replace(each: "\r\n", with: "\n")
  |> string.trim()
  |> string.split(on: "\n\n")
}

/// Checks if a character is digit (0-9)
pub fn is_digit(char: String) -> Bool {
  case <<char:utf8>> {
    <<byte:size(8)>> -> byte >= 48 && byte <= 57
    _ -> False
  }
}

/// Converts a 2D list into a tuple map.
pub fn to_dict_grid(raw_grid: List(List(a))) -> Dict(#(Int, Int), a) {
  use acc, row, y <- list.index_fold(raw_grid, dict.new())
  use acc, val, x <- list.index_fold(row, acc)
  dict.insert(acc, #(x, y), val)
}

/// Returns the n-th element of list xs
pub fn at(xs: List(a), n: Int) -> Result(a, Nil) {
  xs |> list.drop(n) |> list.first
}

/// Returns a list of integers from `start` to `end` (inclusive).
/// This is a replacement for the deprecated `list.range`.
///
/// ## Examples
///
/// ```gleam
/// int_range(1, 5)
/// // => [1, 2, 3, 4, 5]
///
/// int_range(0, 3)
/// // => [0, 1, 2, 3]
/// ```
pub fn int_range(start: Int, end: Int) -> List(Int) {
  do_range(start, end, [])
  |> list.reverse()
}

fn do_range(current: Int, end: Int, acc: List(Int)) -> List(Int) {
  case current > end {
    True -> acc
    False -> do_range(current + 1, end, [current, ..acc])
  }
}

/// Halts a process immediately.
@external(erlang, "erlang", "halt")
@external(javascript, "node:process", "exit")
pub fn exit(status: Int) -> Nil
