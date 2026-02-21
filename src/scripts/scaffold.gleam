import common/cli
import common/reader.{InputParams}
import filepath
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  case cli.input_from_cli() {
    Ok(InputParams(year, day)) -> run_scaffold(year, day)
    Error(_) -> io.println("")
  }
}

fn run_scaffold(year: Int, day: Int) {
  let year_str = int.to_string(year)
  let day_padded = int.to_string(day) |> string.pad_start(2, "0")

  // Using 'filepath' for robust path joining
  let src_path =
    filepath.join("src", "year_" <> year_str)
    |> filepath.join("day_" <> day_padded <> ".gleam")

  let test_path =
    filepath.join("test", "year_" <> year_str)
    |> filepath.join("day_" <> day_padded <> "_test.gleam")

  let input_path =
    filepath.join("inputs", year_str <> "_" <> day_padded <> ".txt")

  [src_path, test_path, input_path]
  |> list.each(fn(path) {
    let dir = filepath.directory_name(path)
    let _ = simplifile.create_directory_all(dir)
  })

  write_if_missing(src_path, generate_solution_module(year, day))
  write_if_missing(test_path, generate_test_module(year, day))
  write_if_missing(input_path, "")

  io.println("✨ Scaffolding complete for " <> year_str <> " Day " <> day_padded)
}

fn write_if_missing(path: String, content: String) {
  case simplifile.is_file(path) {
    Ok(True) -> io.println("  - Skipping: " <> path <> " (exists)")
    _ -> {
      let assert Ok(_) = simplifile.write(path, content)
      io.println("  - Created:  " <> path)
    }
  }
}

fn generate_solution_module(year: Int, day: Int) -> String {
  "/// Title: 
/// Link: https://adventofcode.com/{{year}}/day/{{day}}
/// Difficulty: 
/// Tags: 
import common/reader
import common/solution.{type Solution, Solution, OfInt}
import common/utils
import gleam/result

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  input |> list.length()
}

fn solve_part_2(input: List(Int)) -> Int {
  input |> list.length()
}

fn parse(raw_input: String) -> List(Int) {
  let assert Ok(nums) =
    raw_input 
    |> utils.to_lines() 
    |> utils.to_ints()

  nums
}

pub fn main() -> Nil {
  let param = reader.InputParams({{year}}, {{day}})
  let input = reader.read_input(param) |> result.unwrap(or: \"\")
  solve(input) |> echo

  Nil
}"
  |> string.replace("{{year}}", int.to_string(year))
  |> string.replace("{{day}}", int.to_string(day))
}

fn generate_test_module(year: Int, day: Int) -> String {
  // Ensure day is padded for the module name (e.g., 1 -> "01")
  let day_str = day |> int.to_string |> string.pad_start(to: 2, with: "0")
  let year_str = year |> int.to_string

  let template =
    "import common/reader.{InputParams, read_input}
import common/solution.{Solution, OfInt}
import year_{{year}}/day_{{day_padded}}

pub fn solve_test() {
  let param = InputParams({{year}}, {{day}})
  let assert Ok(input) = read_input(param)

  let got = day_{{day_padded}}.solve(input)
  let expected = Solution(OfInt(5), OfInt(10))

  assert expected == got
}"

  template
  |> string.replace("{{year}}", year_str)
  |> string.replace("{{day}}", int.to_string(day))
  |> string.replace("{{day_padded}}", day_str)
}
