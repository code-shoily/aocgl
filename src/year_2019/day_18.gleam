/// Title: Many-Worlds Interpretation
/// Link: https://adventofcode.com/2019/day/18
/// Difficulty: xl
/// Tags: graph, bfs, shortest-path, state-space-search
import common/reader
import common/solution.{type Solution, OfInt, OfNil, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/pairing_heap
import gleamy/priority_queue as pq

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = OfNil(Nil)
  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> Int {
  let initial_state = State(input.start_label, 0)

  let frontier =
    pq.from_list([#(0, initial_state)], fn(a, b) { int.compare(a.0, b.0) })

  dijkstra_virtual(
    dict.from_list([#(initial_state, 0)]),
    frontier,
    input.adj,
    input.all_keys_mask,
  )
}

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

fn dijkstra_virtual(
  distances: Dict(State, Int),
  frontier: pairing_heap.Heap(#(Int, State)),
  adj: Dict(String, List(Edge)),
  goal_mask: Int,
) -> Int {
  case pq.pop(frontier) {
    Error(Nil) -> -1

    Ok(#(#(dist, state), rest)) -> {
      case state.collected == goal_mask {
        True -> dist
        False -> {
          case dict.get(distances, state) {
            Ok(best) if best < dist ->
              dijkstra_virtual(distances, rest, adj, goal_mask)
            _ -> {
              let neighbors = dict.get(adj, state.at) |> result.unwrap([])
              let #(new_distances, new_frontier) =
                list.fold(neighbors, #(distances, rest), fn(acc, edge) {
                  let #(dists, frontier_acc) = acc
                  let has_required_keys =
                    int.bitwise_and(state.collected, edge.required_mask)
                    == edge.required_mask

                  case has_required_keys {
                    False -> acc
                    True -> {
                      let key_bit = key_to_bit(edge.to)
                      let new_collected =
                        int.bitwise_or(state.collected, key_bit)
                      let new_state = State(edge.to, new_collected)
                      let new_dist = dist + edge.dist
                      let is_better = case dict.get(dists, new_state) {
                        Ok(prev) -> new_dist < prev
                        Error(Nil) -> True
                      }

                      case is_better {
                        False -> acc
                        True -> {
                          let updated_dists =
                            dict.insert(dists, new_state, new_dist)
                          let updated_frontier =
                            pq.push(frontier_acc, #(new_dist, new_state))

                          #(updated_dists, updated_frontier)
                        }
                      }
                    }
                  }
                })
              dijkstra_virtual(new_distances, new_frontier, adj, goal_mask)
            }
          }
        }
      }
    }
  }
}

fn parse(raw_input: String) -> Input {
  let grid_lines = utils.to_lines(raw_input)
  let grid = parse_grid(grid_lines)
  let pois = find_pois(grid)
  let adj =
    dict.fold(pois, dict.new(), fn(acc, label, pos) {
      let edges = find_reachable_keys(grid, pos, pois)

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

fn find_reachable_keys(
  grid: Dict(Pos, String),
  start: Pos,
  _pois: Dict(String, Pos),
) -> List(Edge) {
  bfs_find_keys(grid, [#(start, 0, 0)], set.from_list([start]), [])
}

fn bfs_find_keys(
  grid: Dict(Pos, String),
  queue: List(#(Pos, Int, Int)),
  visited: Set(Pos),
  found: List(Edge),
) -> List(Edge) {
  case queue {
    [] -> found

    [#(pos, dist, door_mask), ..rest] -> {
      let char = dict.get(grid, pos) |> result.unwrap("#")

      let #(new_found, should_continue) = case is_key(char) {
        True if dist > 0 -> {
          let edge = Edge(char, dist, door_mask)
          #([edge, ..found], False)
        }
        _ -> #(found, True)
      }

      case should_continue {
        False -> bfs_find_keys(grid, rest, visited, new_found)
        True -> {
          let new_door_mask = case is_door(char) {
            True -> int.bitwise_or(door_mask, door_to_key_bit(char))
            False -> door_mask
          }

          let neighbors = get_neighbors(pos)

          let #(new_queue, new_visited) =
            list.fold(neighbors, #(rest, visited), fn(acc, neighbor) {
              let #(q, v) = acc
              let neighbor_char = dict.get(grid, neighbor) |> result.unwrap("#")
              case neighbor_char, set.contains(v, neighbor) {
                "#", _ -> acc
                _, True -> acc
                _, False -> #(
                  list.append(q, [#(neighbor, dist + 1, new_door_mask)]),
                  set.insert(v, neighbor),
                )
              }
            })

          bfs_find_keys(grid, new_queue, new_visited, new_found)
        }
      }
    }
  }
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
