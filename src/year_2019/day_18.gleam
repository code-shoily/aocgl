/// Title: Many-Worlds Interpretation
/// Link: https://adventofcode.com/2019/day/18
/// Difficulty: xl
/// Tags: graph dijkstra bfs state-space-search bitmask implicit-graph
import common/reader
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import yog/pathfinding
import yog/traversal.{BreadthFirst, Continue, Stop}

pub fn solve(raw_input: String) -> Solution {
  let input1 = parse(raw_input)
  let input4 = parse_part2(raw_input)
  let part_1 = solve_part_1(input1) |> OfInt
  let part_2 = solve_part_2(input4) |> OfInt
  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> Int {
  pathfinding.implicit_dijkstra(
    from: State(input.start_label, 0),
    successors_with_cost: fn(state) {
      dict.get(input.adj, state.at)
      |> result.unwrap([])
      |> list.filter_map(fn(edge) {
        let has_keys =
          int.bitwise_and(state.collected, edge.required_mask)
          == edge.required_mask
        case has_keys {
          False -> Error(Nil)
          True ->
            Ok(#(
              State(
                edge.to,
                int.bitwise_or(state.collected, key_to_bit(edge.to)),
              ),
              edge.dist,
            ))
        }
      })
    },
    is_goal: fn(state) { state.collected == input.all_keys_mask },
    with_zero: 0,
    with_add: int.add,
    with_compare: int.compare,
  )
  |> option.unwrap(-1)
}

// ── Shared types ──────────────────────────────────────────────────────────────

type Pos =
  #(Int, Int)

type Input {
  Input(adj: Dict(String, List(Edge)), all_keys_mask: Int, start_label: String)
}

type Edge {
  Edge(to: String, dist: Int, required_mask: Int)
}

type State {
  State(at: String, collected: Int)
}

// ── Part 2 types ─────────────────────────────────────────────────────────────

type Input4 {
  Input4(
    adj: Dict(String, List(Edge)),
    all_keys_mask: Int,
    starts: List(String),
  )
}

type State4 {
  State4(robots: List(String), collected: Int)
}

fn solve_part_2(input: Input4) -> Int {
  pathfinding.implicit_dijkstra(
    from: State4(input.starts, 0),
    successors_with_cost: fn(state) {
      list.index_fold(state.robots, [], fn(acc, robot_at, i) {
        let edges = dict.get(input.adj, robot_at) |> result.unwrap([])
        list.fold(edges, acc, fn(acc2, edge) {
          let has_keys =
            int.bitwise_and(state.collected, edge.required_mask)
            == edge.required_mask
          case has_keys {
            False -> acc2
            True -> {
              let new_collected =
                int.bitwise_or(state.collected, key_to_bit(edge.to))
              let new_robots =
                list.index_map(state.robots, fn(label, j) {
                  case i == j {
                    True -> edge.to
                    False -> label
                  }
                })
              [#(State4(new_robots, new_collected), edge.dist), ..acc2]
            }
          }
        })
      })
    },
    is_goal: fn(state) { state.collected == input.all_keys_mask },
    with_zero: 0,
    with_add: int.add,
    with_compare: int.compare,
  )
  |> option.unwrap(-1)
}

// ── Part 2 parsing ────────────────────────────────────────────────────────────

fn parse_part2(raw_input: String) -> Input4 {
  let grid = raw_input |> utils.to_lines() |> parse_grid()

  let start_pos =
    dict.fold(grid, #(0, 0), fn(acc, pos, char) {
      case char {
        "@" -> pos
        _ -> acc
      }
    })
  let #(cx, cy) = start_pos

  let modified =
    grid
    |> dict.insert(#(cx, cy), "#")
    |> dict.insert(#(cx + 1, cy), "#")
    |> dict.insert(#(cx - 1, cy), "#")
    |> dict.insert(#(cx, cy + 1), "#")
    |> dict.insert(#(cx, cy - 1), "#")
    |> dict.insert(#(cx - 1, cy - 1), "1")
    |> dict.insert(#(cx + 1, cy - 1), "2")
    |> dict.insert(#(cx - 1, cy + 1), "3")
    |> dict.insert(#(cx + 1, cy + 1), "4")

  let pois = find_pois_part2(modified)
  let adj =
    dict.fold(pois, dict.new(), fn(acc, label, pos) {
      dict.insert(acc, label, find_reachable_keys(modified, pos))
    })
  let all_keys_mask =
    dict.fold(pois, 0, fn(acc, label, _) {
      case is_key(label) {
        True -> int.bitwise_or(acc, key_to_bit(label))
        False -> acc
      }
    })

  Input4(adj, all_keys_mask, ["1", "2", "3", "4"])
}

fn find_pois_part2(grid: Dict(Pos, String)) -> Dict(String, Pos) {
  dict.fold(grid, dict.new(), fn(acc, pos, char) {
    case char {
      "1" | "2" | "3" | "4" -> dict.insert(acc, char, pos)
      _ ->
        case is_key(char) {
          True -> dict.insert(acc, char, pos)
          False -> acc
        }
    }
  })
}

// ── Shared parse helper ───────────────────────────────────────────────────────

fn parse(raw_input: String) -> Input {
  let grid_lines = utils.to_lines(raw_input)
  let grid = parse_grid(grid_lines)
  let pois = find_pois(grid)
  let adj =
    dict.fold(pois, dict.new(), fn(acc, label, pos) {
      let edges = find_reachable_keys(grid, pos)

      dict.insert(acc, label, edges)
    })

  let all_keys_mask =
    dict.fold(pois, 0, fn(acc, label, _pos) {
      case label {
        "@" -> acc
        _ -> int.bitwise_or(acc, key_to_bit(label))
      }
    })

  Input(adj, all_keys_mask, "@")
}

fn parse_grid(lines: List(String)) -> Dict(Pos, String) {
  lines
  |> list.index_fold(dict.new(), fn(acc, line, y) {
    line
    |> string.to_graphemes()
    |> list.index_fold(acc, fn(inner_acc, char, x) {
      dict.insert(inner_acc, #(x, y), char)
    })
  })
}

fn find_pois(grid: Dict(Pos, String)) -> Dict(String, Pos) {
  dict.fold(grid, dict.new(), fn(acc, pos, char) {
    case char {
      "@" -> dict.insert(acc, "@", pos)
      _ ->
        case is_key(char) {
          True -> dict.insert(acc, char, pos)
          False -> acc
        }
    }
  })
}

fn find_reachable_keys(grid: Dict(Pos, String), start: Pos) -> List(Edge) {
  traversal.implicit_fold_by(
    from: #(start, 0),
    using: BreadthFirst,
    initial: [],
    successors_of: fn(node) {
      let #(pos, door_mask) = node
      get_neighbors(pos)
      |> list.filter_map(fn(nb) {
        case dict.get(grid, nb) |> result.unwrap("#") {
          "#" -> Error(Nil)
          c ->
            Ok(
              #(nb, case is_door(c) {
                True -> int.bitwise_or(door_mask, door_to_key_bit(c))
                False -> door_mask
              }),
            )
        }
      })
    },
    visited_by: fn(node) { node.0 },
    with: fn(found, node, meta) {
      let #(pos, door_mask) = node
      let char = dict.get(grid, pos) |> result.unwrap("#")
      case meta.depth > 0 && is_key(char) {
        True -> #(Stop, [Edge(char, meta.depth, door_mask), ..found])
        False -> #(Continue, found)
      }
    },
  )
}

fn get_neighbors(pos: Pos) -> List(Pos) {
  let #(x, y) = pos
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
}

fn is_key(char: String) -> Bool {
  string.lowercase(char) == char && string.uppercase(char) != char
}

fn is_door(char: String) -> Bool {
  string.uppercase(char) == char && string.lowercase(char) != char
}

fn key_to_bit(key: String) -> Int {
  case string.to_utf_codepoints(key) |> list.first {
    Ok(cp) -> {
      let val = string.utf_codepoint_to_int(cp)
      case val >= 97 && val <= 122 {
        True -> {
          int.bitwise_shift_left(1, val - 97)
        }
        False -> 0
      }
    }
    Error(_) -> 0
  }
}

fn door_to_key_bit(door: String) -> Int {
  case is_door(door) {
    True -> key_to_bit(string.lowercase(door))
    False -> 0
  }
}

// ------------------------------ Exploration
pub fn main() -> Nil {
  let param = reader.InputParams(2019, 18)
  let input = reader.read_input(param) |> result.unwrap(or: "")

  solve(input) |> echo

  utils.exit(0)
}
