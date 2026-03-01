/// Title: Print Queue
/// Link: https://adventofcode.com/2024/day/5
/// Difficulty: m
/// Tags: graph topological-sort
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import yog/builder/labeled
import yog/topological_sort

pub type Input {
  Input(rules: List(#(Int, Int)), updates: List(List(Int)))
}

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> Int {
  input.updates
  |> list.filter(fn(update) { is_valid(update, input.rules) })
  |> list.map(get_middle)
  |> int.sum
}

fn solve_part_2(input: Input) -> Int {
  input.updates
  |> list.filter(fn(update) { !is_valid(update, input.rules) })
  |> list.map(fn(update) { reorder(update, input.rules) })
  |> list.map(get_middle)
  |> int.sum
}

fn is_valid(update: List(Int), rules: List(#(Int, Int))) -> Bool {
  update == reorder(update, rules)
}

fn reorder(update: List(Int), rules: List(#(Int, Int))) -> List(Int) {
  let update_set = set.from_list(update)

  let builder =
    rules
    |> list.filter(fn(rule) {
      set.contains(update_set, rule.0) && set.contains(update_set, rule.1)
    })
    |> list.fold(labeled.directed(), fn(b, rule) {
      labeled.add_edge(b, int.to_string(rule.0), int.to_string(rule.1), 1)
    })

  let graph =
    update
    |> list.fold(builder, fn(b, page) {
      labeled.add_node(b, int.to_string(page))
    })
    |> labeled.to_graph()

  topological_sort.topological_sort(graph)
  |> result.unwrap([])
  |> list.map(fn(node_id) {
    let assert Ok(label) = dict.get(graph.nodes, node_id)
    let assert Ok(val) = int.parse(label)
    val
  })
}

fn get_middle(l: List(Int)) -> Int {
  let len = list.length(l)
  l |> list.drop(len / 2) |> list.first |> result.unwrap(0)
}

fn parse(raw_input: String) -> Input {
  let assert [rules_raw, updates_raw] = string.split(raw_input, on: "\n\n")

  let rules =
    rules_raw
    |> utils.to_lines()
    |> list.map(fn(line) {
      let assert [a, b] = string.split(line, "|")
      let assert Ok(a_int) = int.parse(a)
      let assert Ok(b_int) = int.parse(b)
      #(a_int, b_int)
    })

  let updates =
    updates_raw
    |> utils.to_lines()
    |> list.map(fn(line) {
      string.split(line, ",")
      |> list.map(fn(x) {
        let assert Ok(n) = int.parse(x)
        n
      })
    })

  Input(rules, updates)
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2024, 5)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo
  utils.exit(0)
}
