/// Title: Proboscidea Volcanium
/// Link: https://adventofcode.com/2022/day/16
/// Difficulty: xl
/// Tags: graph floyd-warshall dfs bitmask
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import yog/builder/labeled
import yog/pathfinding

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> Int {
  let scores = compute_all_path_scores(input, 30)
  dict.values(scores) |> list.fold(0, int.max)
}

fn solve_part_2(input: Input) -> Int {
  let scores = compute_all_path_scores(input, 26)
  let scores_list = dict.to_list(scores)

  list.fold(scores_list, 0, fn(max_acc, entry_a) {
    let #(mask_a, score_a) = entry_a
    list.fold(scores_list, max_acc, fn(inner_acc, entry_b) {
      let #(mask_b, score_b) = entry_b
      case int.bitwise_and(mask_a, mask_b) == 0 {
        True -> int.max(inner_acc, score_a + score_b)
        False -> inner_acc
      }
    })
  })
}

type Input {
  Input(
    valve_ids: List(Int),
    valve_flows: Dict(Int, Int),
    distances: Dict(#(Int, Int), Int),
    start_id: Int,
  )
}

fn compute_all_path_scores(input: Input, total_time: Int) -> Dict(Int, Int) {
  do_walk(input, input.start_id, total_time, 0, 0, dict.new())
}

fn do_walk(
  input: Input,
  current_id: Int,
  time: Int,
  mask: Int,
  pressure: Int,
  acc: Dict(Int, Int),
) -> Dict(Int, Int) {
  let current_best = dict.get(acc, mask) |> result.unwrap(0)
  let acc = dict.insert(acc, mask, int.max(current_best, pressure))

  list.fold(input.valve_ids, acc, fn(current_acc, next_valve_id) {
    let valve_index = get_valve_index(input.valve_ids, next_valve_id)
    let is_open =
      int.bitwise_and(mask, int.bitwise_shift_left(1, valve_index)) != 0

    case is_open {
      True -> current_acc
      False -> {
        let assert Ok(dist) =
          dict.get(input.distances, #(current_id, next_valve_id))
        let time_left = time - dist - 1

        case time_left > 0 {
          True -> {
            let assert Ok(flow) = dict.get(input.valve_flows, next_valve_id)
            let next_pressure = pressure + { time_left * flow }
            let next_mask =
              int.bitwise_or(mask, int.bitwise_shift_left(1, valve_index))
            do_walk(
              input,
              next_valve_id,
              time_left,
              next_mask,
              next_pressure,
              current_acc,
            )
          }
          False -> current_acc
        }
      }
    }
  })
}

fn get_valve_index(valve_ids: List(Int), valve_id: Int) -> Int {
  let assert Ok(index) =
    list.index_fold(valve_ids, Error(Nil), fn(acc, id, idx) {
      case id == valve_id {
        True -> Ok(idx)
        False -> acc
      }
    })
  index
}

fn parse(raw_input: String) -> Input {
  let lines =
    raw_input
    |> string.split("\n")
    |> list.filter(fn(l) { l != "" })

  let builder = labeled.directed()

  let #(builder, flow_map) =
    list.fold(lines, #(builder, dict.new()), fn(acc, line) {
      let #(builder, flows) = acc

      let assert Ok(#("Valve " <> valve, _)) =
        string.split_once(line, " has flow")

      let assert Ok(#(_, after_eq)) = string.split_once(line, "=")
      let assert Ok(#(rate_str, _)) = string.split_once(after_eq, ";")
      let assert Ok(flow_rate) = int.parse(string.trim(rate_str))

      let tunnels = case string.contains(line, "valves") {
        True -> {
          let assert Ok(#(_, valves_str)) = string.split_once(line, "valves ")
          string.split(valves_str, ", ")
        }
        False -> {
          let assert Ok(#(_, valve_str)) = string.split_once(line, "valve ")
          [valve_str]
        }
      }

      let builder =
        list.fold(tunnels, builder, fn(b, dest) {
          labeled.add_edge(b, valve, dest, 1)
        })

      #(builder, dict.insert(flows, valve, flow_rate))
    })

  let graph = labeled.to_graph(builder)
  let label_to_id = builder.label_to_id

  let valve_flows =
    dict.fold(flow_map, dict.new(), fn(acc, label, rate) {
      let assert Ok(id) = dict.get(label_to_id, label)
      dict.insert(acc, id, rate)
    })

  let assert Ok(distances) =
    pathfinding.floyd_warshall(
      graph,
      with_zero: 0,
      with_add: int.add,
      with_compare: int.compare,
    )

  let assert Ok(start_id) = dict.get(label_to_id, "AA")

  let valve_ids =
    dict.filter(valve_flows, fn(_, rate) { rate > 0 })
    |> dict.keys()

  Input(valve_ids, valve_flows, distances, start_id)
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2022, 16)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo

  utils.exit(0)
}
