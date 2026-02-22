//// This module handles the ingestion of raw text files for Advent of Code.
//// It ensures adherence to the 2025 "12-day" rule change.

import filepath
import gleam/int
import gleam/result
import gleam/string
import simplifile

pub type InputParams {
  InputParams(year: Int, day: Int)
}

pub type ParameterError {
  InvalidDayParam
  InvalidYearParam
}

pub type ReaderError {
  ParameterError(kind: ParameterError)
  SystemError(simplifile.FileError)
}

/// Reads the puzzle input from the local file system.
/// 
/// Returns `Error(ParameterError)` if the date is outside the valid 
/// range (2015-2025).
pub fn read_input(params: InputParams) -> Result(String, ReaderError) {
  use valid_params <- result.try(is_valid_params(params))
  use path <- result.try(get_path_for(valid_params))

  simplifile.read(from: path) |> result.map_error(SystemError)
}

fn get_path_for(params: InputParams) -> Result(String, ReaderError) {
  let file =
    int.to_string(params.year)
    <> "_"
    <> params.day |> int.to_string() |> string.pad_start(2, "0")
    <> ".txt"

  simplifile.current_directory()
  |> result.map(fn(base) {
    base |> filepath.join("inputs") |> filepath.join(file)
  })
  |> result.map_error(SystemError)
}

fn is_valid_params(params: InputParams) -> Result(InputParams, ReaderError) {
  case params {
    InputParams(year: year, day: _) if 2015 <= year && year <= 2025 ->
      is_valid_day(params)
    _ -> Error(ParameterError(InvalidYearParam))
  }
}

fn is_valid_day(params: InputParams) -> Result(InputParams, ReaderError) {
  case params {
    InputParams(year: 2025, day: day) if day >= 1 && day <= 12 -> Ok(params)
    InputParams(year: year, day: day) if day >= 1 && day <= 25 && year != 2025 ->
      Ok(params)
    _ -> Error(ParameterError(InvalidDayParam))
  }
}
