import gleam/dict.{type Dict}
import gleam/float
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

/// Runs a function and returns the result along with the time taken in microseconds.
/// Designed to be used with pipelines: `input |> utils.timed(solve)`
pub fn timed(input: a, solve: fn(a) -> b) -> #(b, Int) {
  let start = timestamp() |> to_micros
  let res = solve(input)
  let end = timestamp() |> to_micros
  #(res, end - start)
}

@external(erlang, "os", "timestamp")
pub fn timestamp() -> #(Int, Int, Int)

pub fn to_micros(t: #(Int, Int, Int)) -> Int {
  let #(mega, sec, micro) = t
  mega * 1_000_000_000_000 + sec * 1_000_000 + micro
}

/// Halts a process immediately.
@external(erlang, "erlang", "halt")
@external(javascript, "node:process", "exit")
pub fn exit(status: Int) -> Nil

/// Computes the greatest common divisor of two integers.
pub fn gcd(a: Int, b: Int) -> Int {
  let a = int.absolute_value(a)
  let b = int.absolute_value(b)
  case b {
    0 -> a
    _ -> gcd(b, a % b)
  }
}

/// Computes the least common multiple of two integers.
pub fn lcm(a: Int, b: Int) -> Int {
  let a_abs = int.absolute_value(a)
  let b_abs = int.absolute_value(b)
  case a_abs == 0 || b_abs == 0 {
    True -> 0
    False -> a_abs * b_abs / gcd(a_abs, b_abs)
  }
}

/// Counts the number of digits in an integer
pub fn count_digits(n: Int) -> Int {
  let abs_n = int.absolute_value(n)
  case abs_n {
    0 -> 1
    _ -> {
      let ln_n = float.logarithm(int.to_float(abs_n))
      let ln_10 = float.logarithm(10.0)

      case ln_n, ln_10 {
        Ok(val), Ok(base) -> {
          let log10_val = val /. base
          float.floor(log10_val) |> float.round |> int.add(1)
        }
        _, _ -> 1
      }
    }
  }
}

/// Exponentiation with int args, helps with floating point roundoffs if dealing
/// with integers only.
pub fn int_pow(base: Int, exp: Int) -> Int {
  do_int_pow(base, exp, 1)
}

fn do_int_pow(base: Int, exp: Int, acc: Int) -> Int {
  case exp {
    0 -> acc
    _ -> do_int_pow(base, exp - 1, acc * base)
  }
}

@external(erlang, "erlang", "md5")
pub fn md5(data: BitArray) -> BitArray
