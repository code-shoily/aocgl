/// Title: LAN Party
/// Link: https://adventofcode.com/2024/day/23
/// Difficulty: m
/// Tags: graph clique bron-kerbosch
import common/solution.{type Solution, OfInt, OfStr, Solution}
import common/utils
import gleam/dict
import gleam/list
import gleam/set.{type Set}
import gleam/string
import yog/builder/labeled
import yog/model
import yog/property/clique as properties

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

    case v > u {
      False -> []
      True -> {
        let v_neighbors = get_neighbor_ids_set(input.graph, v)
        let common_neighbors = set.intersection(u_neighbors, v_neighbors)

        use w <- list.filter_map(set.to_list(common_neighbors))
        let w_name = get_name(input, w)

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
  input.graph
  |> properties.max_clique
  |> set.to_list
  |> list.map(fn(id) { get_name(input, id) })
  |> list.sort(string.compare)
  |> string.join(",")
}

type Input {
  Input(graph: model.Graph(String, Nil), builder: labeled.Builder(String, Nil))
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

fn get_neighbor_ids_set(graph: model.Graph(n, e), id: Int) -> Set(Int) {
  model.neighbors(graph, id)
  |> list.map(fn(neighbor) { neighbor.0 })
  |> set.from_list
}
// ------------------------------ Explorations
// import common/reader.{InputParams}

// pub fn main() {
//   let assert Ok(input) = InputParams(2024, 23) |> reader.read_input

//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
