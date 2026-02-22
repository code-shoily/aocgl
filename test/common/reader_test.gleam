import common/reader.{
  InputParams, InvalidDayParam, InvalidYearParam, ParameterError, read_input,
}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// --- Year Validation (2015-2025) ---

pub fn valid_year_range_test() {
  InputParams(year: 2015, day: 1)
  |> read_input()
  |> should.not_equal(Error(ParameterError(InvalidYearParam)))

  InputParams(year: 2025, day: 1)
  |> read_input()
  |> should.not_equal(Error(ParameterError(InvalidYearParam)))

  InputParams(year: 2020, day: 1)
  |> read_input()
  |> should.not_equal(Error(ParameterError(InvalidYearParam)))
}

pub fn invalid_year_boundaries_test() {
  [2014, 2026, 1999]
  |> list.each(fn(year) {
    InputParams(year: year, day: 1)
    |> read_input()
    |> should.equal(Error(ParameterError(InvalidYearParam)))
  })
}

// --- Day Validation (1-25) ---

pub fn valid_day_range_test() {
  [1, 15, 25]
  |> list.each(fn(day) {
    InputParams(year: 2020, day: day)
    |> read_input()
    |> should.not_equal(Error(ParameterError(InvalidDayParam)))
  })
}

pub fn invalid_day_boundaries_test() {
  [0, -1, 26, 100]
  |> list.each(fn(day) {
    InputParams(year: 2020, day: day)
    |> read_input()
    |> should.equal(Error(ParameterError(InvalidDayParam)))
  })
}

// --- 2025 Special Rules & Edge Cases ---

pub fn year_2025_special_rules_test() {
  // Day 1 & 12 should always be valid
  InputParams(year: 2025, day: 1)
  |> read_input()
  |> should.not_equal(Error(ParameterError(InvalidDayParam)))

  InputParams(year: 2025, day: 12)
  |> read_input()
  |> should.not_equal(Error(ParameterError(InvalidDayParam)))

  InputParams(year: 2025, day: 13)
  |> read_input()
  |> should.equal(Error(ParameterError(InvalidDayParam)))
}

pub fn error_precedence_test() {
  InputParams(year: 2026, day: 0)
  |> read_input()
  |> should.equal(Error(ParameterError(InvalidYearParam)))
}
