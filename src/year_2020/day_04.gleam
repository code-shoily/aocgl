/// Title: Passport Processing
/// Link: https://adventofcode.com/2020/day/4
/// Difficulty: s
/// Tags: validation
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set
import gleam/string
import rectify.{type Validation, invalid, valid}

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let valid_passports = list.filter(input, contains_required_fields)

  let part_1 = list.length(valid_passports) |> OfInt
  let part_2 = valid_passports |> solve_part_2() |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_2(input: List(Dict(String, String))) -> Int {
  input
  |> list.map(validate_passport)
  |> list.count(rectify.is_valid)
}

fn parse(raw_input: String) -> List(Dict(String, String)) {
  raw_input
  |> utils.to_paragraphs
  |> list.map(to_passport_line)
}

fn to_passport_line(line: String) -> Dict(String, String) {
  line
  |> string.replace(each: "\n", with: " ")
  |> string.split(on: " ")
  |> list.map(fn(token) {
    let assert [left, right] = string.split(token, ":")
    #(left, right)
  })
  |> dict.from_list
}

fn contains_required_fields(passport: Dict(String, String)) -> Bool {
  passport
  |> dict.keys()
  |> set.from_list()
  |> set.is_subset(
    set.from_list(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]),
    _,
  )
}

type Passport {
  Passport(
    byr: Int,
    iyr: Int,
    eyr: Int,
    hgt: Int,
    hcl: Int,
    ecl: String,
    pid: String,
  )
}

fn validate_passport(
  passport: Dict(String, String),
) -> Validation(Passport, Nil) {
  map7(
    passport |> field("byr", validate_between(_, 1920, 2002)),
    passport |> field("iyr", validate_between(_, 2010, 2020)),
    passport |> field("eyr", validate_between(_, 2020, 2030)),
    passport |> field("hgt", validate_hgt),
    passport |> field("hcl", validate_hcl),
    passport |> field("ecl", validate_ecl),
    passport |> field("pid", validate_pid),
    Passport,
  )
}

fn validate_between(value: String, from: Int, to: Int) -> Validation(Int, Nil) {
  case int.parse(value) {
    Ok(value) if from <= value && value <= to -> valid(value)
    _ -> invalid(Nil)
  }
}

fn validate_hcl(value: String) -> Validation(Int, Nil) {
  case value, string.length(value) {
    "#" <> rest, 7 -> {
      int.base_parse(rest, 16) |> rectify.of_result()
    }
    _, _ -> invalid(Nil)
  }
}

fn validate_ecl(value: String) -> Validation(String, Nil) {
  set.from_list(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])
  |> set.contains(value)
  |> rectify.of_bool(value, Nil)
}

fn validate_pid(value: String) -> Validation(String, Nil) {
  case int.parse(value), string.length(value) {
    Ok(_), 9 -> valid(value)
    _, _ -> invalid(Nil)
  }
}

fn validate_hgt(value: String) -> Validation(Int, Nil) {
  case
    string.drop_end(value, 2),
    string.drop_start(value, string.length(value) - 2)
  {
    value, "cm" -> validate_between(value, 150, 193)
    value, "in" -> validate_between(value, 59, 76)
    _, _ -> invalid(Nil)
  }
}

fn field(key: String, validate: fn(String) -> Validation(a, Nil)) {
  fn(dict) {
    dict.get(dict, key) |> rectify.of_result() |> rectify.bind(validate)
  }
}

fn map7(v1, v2, v3, v4, v5, v6, v7, combiner) {
  let first5 =
    rectify.map5(v1, v2, v3, v4, v5, fn(a, b, c, d, e) { #(a, b, c, d, e) })
  let last2 = rectify.map2(v6, v7, fn(g, h) { #(g, h) })

  use #(a, b, c, d, e), #(g, h) <- rectify.map2(first5, last2)
  combiner(a, b, c, d, e, g, h)
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2020, 4) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
