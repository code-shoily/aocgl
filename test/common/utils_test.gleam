import common/utils
import gleam/dict
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn to_lines_basic_test() {
  "line1\nline2\nline3"
  |> utils.to_lines()
  |> should.equal(["line1", "line2", "line3"])
}

pub fn to_lines_crlf_test() {
  "line1\r\nline2\r\nline3"
  |> utils.to_lines()
  |> should.equal(["line1", "line2", "line3"])
}

pub fn to_lines_mixed_line_endings_test() {
  "line1\r\nline2\nline3\r\nline4"
  |> utils.to_lines()
  |> should.equal(["line1", "line2", "line3", "line4"])
}

pub fn to_lines_with_trailing_newline_test() {
  "line1\nline2\n"
  |> utils.to_lines()
  |> should.equal(["line1", "line2"])
}

pub fn to_lines_with_leading_newline_test() {
  "\nline1\nline2"
  |> utils.to_lines()
  |> should.equal(["line1", "line2"])
}

pub fn to_lines_with_surrounding_whitespace_test() {
  "  \nline1\nline2\n  "
  |> utils.to_lines()
  |> should.equal(["line1", "line2"])
}

pub fn to_lines_single_line_test() {
  "single line"
  |> utils.to_lines()
  |> should.equal(["single line"])
}

pub fn to_lines_empty_string_test() {
  ""
  |> utils.to_lines()
  |> should.equal([""])
}

pub fn to_lines_only_whitespace_test() {
  "   \n   \n   "
  |> utils.to_lines()
  |> should.equal([""])
}

// Tests for to_ints()

pub fn to_ints_valid_numbers_test() {
  ["1", "2", "3", "42", "100"]
  |> utils.to_ints()
  |> should.be_ok()
  |> should.equal([1, 2, 3, 42, 100])
}

pub fn to_ints_negative_numbers_test() {
  ["-1", "-42", "0", "100"]
  |> utils.to_ints()
  |> should.be_ok()
  |> should.equal([-1, -42, 0, 100])
}

pub fn to_ints_invalid_number_test() {
  ["1", "not a number", "3"]
  |> utils.to_ints()
  |> should.be_error()
}

pub fn to_ints_empty_string_test() {
  ["1", "", "3"]
  |> utils.to_ints()
  |> should.be_error()
}

pub fn to_ints_float_like_string_test() {
  ["1", "2.5", "3"]
  |> utils.to_ints()
  |> should.be_error()
}

pub fn to_ints_empty_list_test() {
  []
  |> utils.to_ints()
  |> should.be_ok()
  |> should.equal([])
}

pub fn to_ints_with_whitespace_test() {
  ["1 ", " 2", " 3 "]
  |> utils.to_ints()
  |> should.be_error()
}

// Tests for to_paragraphs()

pub fn to_paragraphs_basic_test() {
  "para1\n\npara2\n\npara3"
  |> utils.to_paragraphs()
  |> should.equal(["para1", "para2", "para3"])
}

pub fn to_paragraphs_crlf_test() {
  "para1\r\n\r\npara2\r\n\r\npara3"
  |> utils.to_paragraphs()
  |> should.equal(["para1", "para2", "para3"])
}

pub fn to_paragraphs_mixed_line_endings_test() {
  "para1\r\n\r\npara2\n\npara3"
  |> utils.to_paragraphs()
  |> should.equal(["para1", "para2", "para3"])
}

pub fn to_paragraphs_multiline_paragraphs_test() {
  "line1\nline2\n\nline3\nline4\nline5"
  |> utils.to_paragraphs()
  |> should.equal(["line1\nline2", "line3\nline4\nline5"])
}

pub fn to_paragraphs_single_paragraph_test() {
  "single paragraph"
  |> utils.to_paragraphs()
  |> should.equal(["single paragraph"])
}

pub fn to_paragraphs_with_trailing_double_newline_test() {
  "para1\n\npara2\n\n"
  |> utils.to_paragraphs()
  |> should.equal(["para1", "para2"])
}

pub fn to_paragraphs_with_leading_double_newline_test() {
  "\n\npara1\n\npara2"
  |> utils.to_paragraphs()
  |> should.equal(["para1", "para2"])
}

pub fn to_paragraphs_empty_string_test() {
  ""
  |> utils.to_paragraphs()
  |> should.equal([""])
}

pub fn is_digit_test() {
  let test_cases = [
    #("0", True),
    #("9", True),
    #("5", True),
    #("/", False),
    #(":", False),
    #("a", False),
    #(" ", False),
    #("!", False),
    #("12", False),
    #("", False),
  ]

  test_cases
  |> list.each(fn(case_data) {
    let #(input, expected) = case_data
    utils.is_digit(input)
    |> should.equal(expected)
  })
}

pub fn to_dict_grid_square_test() {
  let input = [["1", "2"], ["3", "4"]]

  let grid = utils.to_dict_grid(input)

  grid |> dict.get(#(0, 0)) |> should.equal(Ok("1"))
  grid |> dict.get(#(1, 0)) |> should.equal(Ok("2"))
  grid |> dict.get(#(0, 1)) |> should.equal(Ok("3"))
  grid |> dict.get(#(1, 1)) |> should.equal(Ok("4"))
  grid |> dict.size() |> should.equal(4)
}

pub fn to_dict_grid_rectangular_test() {
  let input = [["A", "B", "C"]]

  let grid = utils.to_dict_grid(input)

  grid |> dict.get(#(0, 0)) |> should.equal(Ok("A"))
  grid |> dict.get(#(1, 0)) |> should.equal(Ok("B"))
  grid |> dict.get(#(2, 0)) |> should.equal(Ok("C"))
  grid |> dict.size() |> should.equal(3)
}

pub fn to_dict_grid_empty_test() {
  let input = []
  utils.to_dict_grid(input) |> dict.size() |> should.equal(0)
}

// Tests for at()

pub fn at_first_element_test() {
  [1, 2, 3, 4, 5]
  |> utils.at(0)
  |> should.be_ok()
  |> should.equal(1)
}

pub fn at_middle_element_test() {
  [1, 2, 3, 4, 5]
  |> utils.at(2)
  |> should.be_ok()
  |> should.equal(3)
}

pub fn at_last_element_test() {
  [1, 2, 3, 4, 5]
  |> utils.at(4)
  |> should.be_ok()
  |> should.equal(5)
}

pub fn at_index_out_of_bounds_test() {
  [1, 2, 3]
  |> utils.at(5)
  |> should.be_error()
}

pub fn at_negative_index_test() {
  // Note: list.drop with negative n doesn't drop anything,
  // so negative index returns the first element
  [1, 2, 3]
  |> utils.at(-1)
  |> should.be_ok()
  |> should.equal(1)
}

pub fn at_empty_list_test() {
  []
  |> utils.at(0)
  |> should.be_error()
}

pub fn at_single_element_list_test() {
  [42]
  |> utils.at(0)
  |> should.be_ok()
  |> should.equal(42)
}

pub fn at_single_element_list_out_of_bounds_test() {
  [42]
  |> utils.at(1)
  |> should.be_error()
}

pub fn at_strings_test() {
  ["apple", "banana", "cherry"]
  |> utils.at(1)
  |> should.be_ok()
  |> should.equal("banana")
}

// Basic range
pub fn range_basic_test() {
  utils.int_range(1, 5)
  |> should.equal([1, 2, 3, 4, 5])
}

// Range starting from 0
pub fn range_from_zero_test() {
  utils.int_range(0, 3)
  |> should.equal([0, 1, 2, 3])
}

// Single element range
pub fn range_single_element_test() {
  utils.int_range(5, 5)
  |> should.equal([5])
}

// Empty range (start > end)
pub fn range_empty_test() {
  utils.int_range(5, 3)
  |> should.equal([])
}

// Large range
pub fn range_large_test() {
  let result = utils.int_range(1, 100)

  // Check length
  list.length(result)
  |> should.equal(100)

  // Check first and last elements
  result
  |> should.equal([
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78,
    79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97,
    98, 99, 100,
  ])
}

// Negative numbers
pub fn range_negative_test() {
  utils.int_range(-3, 2)
  |> should.equal([-3, -2, -1, 0, 1, 2])
}

// Range with negative start and end
pub fn range_all_negative_test() {
  utils.int_range(-5, -2)
  |> should.equal([-5, -4, -3, -2])
}
