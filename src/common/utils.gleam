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

/// Returns numbers ranging from i to f
pub fn int_range(i: Int, f: Int) -> List(Int) {
  int.range(f, i, with: [], run: list.prepend)
}

/// Halts a process immediately.
@external(erlang, "erlang", "halt")
@external(javascript, "node:process", "exit")
pub fn exit(status: Int) -> Nil
