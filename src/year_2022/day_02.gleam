/// Title: Rock Paper Scissors
/// Link: https://adventofcode.com/2022/day/2
/// Difficulty: xs
/// Tags: simulation
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/int
import gleam/list
import gleam/string

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = input |> play(strategy_1, score_1) |> OfInt
  let part_2 = input |> play(strategy_2, score_2) |> OfInt

  Solution(part_1, part_2)
}

fn parse(raw_input: String) -> List(#(String, String)) {
  raw_input
  |> utils.to_lines()
  |> list.map(parse_line)
}

fn play(
  input: List(#(String, String)),
  strategy: fn(#(String, String)) -> a,
  score: fn(a) -> Int,
) -> Int {
  input
  |> list.map(strategy)
  |> list.map(score)
  |> int.sum
}

// --------------------------------------------- Types & Constants
const rock = 1

const paper = 2

const scissor = 3

const win = 6

const lose = 0

const draw = 3

type Selection {
  Rock
  Paper
  Scissor
}

fn to_selection(ch: String) -> Selection {
  case ch {
    "A" | "X" -> Rock
    "B" | "Y" -> Paper
    "C" | "Z" -> Scissor
    _ -> panic
  }
}

type Outcome {
  Win
  Lose
  Draw
}

fn to_outcome(ch: String) {
  case ch {
    "X" -> Lose
    "Y" -> Draw
    "Z" -> Win
    _ -> panic
  }
}

// --------------------------------------------- Selection based Strategy
fn strategy_1(line: #(String, String)) -> #(Selection, Selection) {
  #(to_selection(line.0), to_selection(line.1))
}

fn score_1(strategy: #(Selection, Selection)) -> Int {
  case strategy {
    #(Rock, Rock) -> rock + draw
    #(Rock, Paper) -> paper + win
    #(Rock, Scissor) -> scissor + lose
    #(Paper, Rock) -> rock + lose
    #(Paper, Paper) -> paper + draw
    #(Paper, Scissor) -> scissor + win
    #(Scissor, Rock) -> rock + win
    #(Scissor, Paper) -> paper + lose
    #(Scissor, Scissor) -> scissor + draw
  }
}

// --------------------------------------------- Expected Outcome based Strategy
fn strategy_2(line: #(String, String)) -> #(Selection, Outcome) {
  #(to_selection(line.0), to_outcome(line.1))
}

fn score_2(strategy: #(Selection, Outcome)) -> Int {
  case strategy {
    #(Rock, Win) -> paper + win
    #(Rock, Lose) -> scissor + lose
    #(Rock, Draw) -> rock + draw
    #(Paper, Win) -> scissor + win
    #(Paper, Lose) -> rock + lose
    #(Paper, Draw) -> paper + draw
    #(Scissor, Win) -> rock + win
    #(Scissor, Lose) -> paper + lose
    #(Scissor, Draw) -> scissor + draw
  }
}

fn parse_line(line: String) -> #(String, String) {
  let assert [left, right] = string.split(line, on: " ")
  #(left, right)
}

// ------------------------------ Exploration
import common/reader.{InputParams}

pub fn main() -> Nil {
  let assert Ok(input) = InputParams(2022, 2) |> reader.read_input
  input |> utils.timed(solve) |> echo

  utils.exit(0)
}
