import common/utils
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
