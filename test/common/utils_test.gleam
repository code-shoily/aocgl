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

// Tests for int_range()
// Note: int.range with prepend includes 'from', excludes 'to', returns descending

pub fn int_range_basic_test() {
  // From 1 to 5: includes 1, excludes 5, returns [4, 3, 2, 1]
  utils.int_range(1, 5)
  |> should.equal([4, 3, 2, 1])
}

pub fn int_range_same_value_test() {
  // When from == to, returns empty list
  utils.int_range(3, 3)
  |> should.equal([])
}

pub fn int_range_adjacent_values_test() {
  // When values are adjacent, returns single element [from]
  utils.int_range(5, 6)
  |> should.equal([5])
}

pub fn int_range_reverse_order_test() {
  // from > to: returns ascending [to+1, to+2, ..., from]
  utils.int_range(5, 1)
  |> should.equal([2, 3, 4, 5])
}

pub fn int_range_zero_to_positive_test() {
  // From 0 to 3: includes 0, excludes 3, returns [2, 1, 0]
  utils.int_range(0, 3)
  |> should.equal([2, 1, 0])
}

pub fn int_range_negative_to_positive_test() {
  // From -2 to 2: includes -2, excludes 2, returns [1, 0, -1, -2]
  utils.int_range(-2, 2)
  |> should.equal([1, 0, -1, -2])
}

pub fn int_range_negative_to_negative_test() {
  // From -5 to -2: includes -5, excludes -2, returns [-3, -4, -5]
  utils.int_range(-5, -2)
  |> should.equal([-3, -4, -5])
}

pub fn int_range_large_range_test() {
  let result = utils.int_range(1, 10)
  // Should have 9 elements: [9, 8, 7, 6, 5, 4, 3, 2, 1]
  result |> list.length() |> should.equal(9)
  result |> list.first() |> should.equal(Ok(9))
  result |> list.last() |> should.equal(Ok(1))
}

pub fn int_range_zero_span_test() {
  // From 0 to 10: includes 0, excludes 10, returns [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
  let result = utils.int_range(0, 10)
  result |> list.length() |> should.equal(10)
  result |> should.equal([9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
}
