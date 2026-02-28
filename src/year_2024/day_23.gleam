/// Title: LAN Party
/// Link: https://adventofcode.com/2024/day/23
/// Difficulty: m
/// Tags: graph scc
import common/reader
import common/solution.{type Solution, OfInt, OfStr, Solution}
import common/utils
import gleam/dict
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import yog/builder/labeled
import yog/model

pub type Input {
  Input(graph: model.Graph(String, Nil), builder: labeled.Builder(String, Nil))
}

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfStr

  Solution(part_1, part_2)
}

fn solve_part_1(input: Input) -> Int {
  let nodes = dict.keys(input.graph.nodes)

  let triangles = {
    use u <- list.flat_map(nodes)
    let u_name = get_name(input, u)
    let u_neighbors = get_neighbor_ids_set(input.graph, u)

    use v <- list.flat_map(set.to_list(u_neighbors))
    let v_name = get_name(input, v)

    // Optimization: only process if u < v to avoid duplicate pairs
    case v > u {
      False -> []
      True -> {
        let v_neighbors = get_neighbor_ids_set(input.graph, v)
        let common_neighbors = set.intersection(u_neighbors, v_neighbors)

        use w <- list.filter_map(set.to_list(common_neighbors))
        let w_name = get_name(input, w)

        // Only process if v < w to ensure we only count the triplet (u, v, w) once
        case w > v {
          False -> Error(Nil)
          True -> {
            let names = [u_name, v_name, w_name]
            let has_t =
              list.any(names, fn(name) { string.starts_with(name, "t") })

            case has_t {
              True -> Ok([u, v, w])
              False -> Error(Nil)
            }
          }
        }
      }
    }
  }

  list.length(triangles)
}

fn solve_part_2(input: Input) -> String {
  let p = dict.keys(input.graph.nodes) |> set.from_list
  let max_clique_ids = find_max_clique(input.graph, set.new(), p, set.new())

  max_clique_ids
  |> set.to_list
  |> list.map(fn(id) { get_name(input, id) })
  |> list.sort(string.compare)
  |> string.join(",")
}

fn get_name(input: Input, id: Int) -> String {
  let assert Ok(name) = dict.get(input.graph.nodes, id)
  name
}

fn parse(raw_input: String) -> Input {
  let builder =
    raw_input
    |> utils.to_lines()
    |> list.fold(labeled.undirected(), fn(b, line) {
      let assert [from, to] = string.split(line, "-")
      labeled.add_unweighted_edge(b, from, to)
    })

  Input(labeled.to_graph(builder), builder)
}

// ------------------------------ Port to Yog
fn get_neighbor_ids_set(graph: model.Graph(n, e), id: Int) -> Set(Int) {
  model.neighbors(graph, id)
  |> list.map(fn(neighbor) { neighbor.0 })
  |> set.from_list
}

fn find_max_clique(
  graph: model.Graph(n, e),
  r: Set(Int),
  p: Set(Int),
  x: Set(Int),
) -> Set(Int) {
  case set.is_empty(p) && set.is_empty(x) {
    True -> r
    False -> {
      let pivot =
        set.union(p, x)
        |> set.to_list
        |> list.first
        |> result.unwrap(-1)

      let pivot_neighbors = get_neighbor_ids_set(graph, pivot)
      let candidates = set.drop(p, set.to_list(pivot_neighbors))

      set.to_list(candidates)
      |> list.fold(#(p, x, set.new()), fn(acc, v) {
        let #(curr_p, curr_x, best_r) = acc
        let v_neighbors = get_neighbor_ids_set(graph, v)

        let recursive_r =
          find_max_clique(
            graph,
            set.insert(r, v),
            set.intersection(curr_p, v_neighbors),
            set.intersection(curr_x, v_neighbors),
          )

        let new_best = case set.size(recursive_r) > set.size(best_r) {
          True -> recursive_r
          False -> best_r
        }

        #(set.delete(curr_p, v), set.insert(curr_x, v), new_best)
      })
      |> fn(res) { res.2 }
    }
  }
}

pub fn main() -> Nil {
  let param = reader.InputParams(2024, 23)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> echo
  utils.exit(0)
}
