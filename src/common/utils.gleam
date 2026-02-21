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
