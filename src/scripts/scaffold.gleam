import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import filepath
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn year_opt() -> Opt(Int) {
  "year" |> opt.new() |> opt.int |> opt.help("Year")
}

fn day_opt() -> Opt(Int) {
  "day" |> opt.new() |> opt.int |> opt.help("Day")
}

pub fn command() -> Command(#(Int, Int)) {
  clip.command({ fn(year) { fn(day) { #(year, day) } } })
  |> clip.opt(year_opt())
  |> clip.opt(day_opt())
}

pub fn input_from_cli() -> Result(#(Int, Int), String) {
  command()
  |> clip.help(help.simple(
    "input",
    "[Usage] `gleam run -- --year <year> --day <day>",
  ))
  |> clip.run(argv.load().arguments)
}

pub fn main() -> Nil {
  case input_from_cli() {
    Ok(#(year, day)) -> run_scaffold(year, day)
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

  // 1. Ensure parent directories exist
  [src_path, test_path, input_path]
  |> list.each(fn(path) {
    let dir = filepath.directory_name(path)
    let _ = simplifile.create_directory_all(dir)
  })

  // 2. Process Artifacts with no-op logic
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
import common/solution.{type Solution}
import gleam/result

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input)
  let part_2 = solve_part_2(input)

  todo
}

fn solve_part_1(input: List(Int)) {
  todo
}

fn solve_part_2(input: List(Int)) {
  todo
}

fn parse(raw_input: String) {
  todo
}

pub fn main() -> Nil {
  let param = reader.InputParams({{year}}, {{day}})
  let input = reader.read_input(param) |> result.unwrap(or: \"\")
  solve(input) |> solution.print_solution

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
    "import common/reader
import common/solution.{Solution}
import gleam/result
import year_{{year}}/day_{{day_padded}}

pub fn solve_test() {
  let param = reader.InputParams({{year}}, {{day}})
  let input = reader.read_input(param) |> result.unwrap(or: \"\")
  let result = day_{{day_padded}}.solve(input)

  // Example: let assert Solution(OfInt(5), OfInt(10)) = result
  todo
}"

  template
  |> string.replace("{{year}}", year_str)
  |> string.replace("{{day}}", int.to_string(day))
  |> string.replace("{{day_padded}}", day_str)
}
