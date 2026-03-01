/// Title: Air Duct Spelunking
/// Link: https://adventofcode.com/2016/day/24
/// Difficulty: l
/// Tags: graph bfs tsp
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

pub type Pos =
  #(Int, Int)

pub type Input {
  Input(distances: Dict(#(Int, Int), Int), poi_count: Int)
}

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

const infinity = 999_999_999

fn solve_part_1(input: Input) -> Int {
  let targets = utils.int_range(1, input.poi_count - 1)

  list.permutations(targets)
  |> list.map(fn(p) { calculate_path_dist(input.distances, [0, ..p]) })
  |> list.fold(infinity, int.min)
}

fn solve_part_2(input: Input) -> Int {
  let targets = utils.int_range(1, input.poi_count - 1)

  list.permutations(targets)
  |> list.map(fn(p) {
    let path = list.flatten([[0], p, [0]])
    calculate_path_dist(input.distances, path)
  })
  |> list.fold(infinity, int.min)
}

fn calculate_path_dist(
  distances: Dict(#(Int, Int), Int),
  path: List(Int),
) -> Int {
  path
  |> list.window_by_2
  |> list.fold(0, fn(acc, pair) {
    let assert Ok(d) = dict.get(distances, pair)
    acc + d
  })
}

fn parse(raw_input: String) -> Input {
  let lines = utils.to_lines(raw_input)
  let grid = parse_grid(lines)
  let pois = find_pois(grid)

  let builder =
    dict.fold(grid, labeled.undirected(), fn(b, pos, char) {
      case char {
        "#" -> b
        _ -> {
          let #(x, y) = pos
          let pos_label = string.inspect(pos)

          [#(x + 1, y), #(x, y + 1)]
          |> list.fold(b, fn(acc_b, neighbor) {
            case dict.get(grid, neighbor) {
              Ok(c) if c != "#" ->
                labeled.add_edge(acc_b, pos_label, string.inspect(neighbor), 1)
              _ -> acc_b
            }
          })
        }
      }
    })

  let graph = labeled.to_graph(builder)

  let poi_dist =
    dict.fold(pois, dict.new(), fn(acc, label_a, pos_a) {
      let assert Ok(start_id) =
        dict.get(builder.label_to_id, string.inspect(pos_a))

      let distances =
        pathfinding.single_source_distances(
          in: graph,
          from: start_id,
          with_zero: 0,
          with_add: int.add,
          with_compare: int.compare,
        )

      dict.fold(pois, acc, fn(acc2, label_b, pos_b) {
        let assert Ok(end_id) =
          dict.get(builder.label_to_id, string.inspect(pos_b))
        let assert Ok(dist) = dict.get(distances, end_id)
        dict.insert(acc2, #(label_a, label_b), dist)
      })
    })

  Input(poi_dist, dict.size(pois))
}

fn parse_grid(lines: List(String)) -> Dict(Pos, String) {
  list.index_fold(lines, dict.new(), fn(acc, line, y) {
    list.index_fold(string.to_graphemes(line), acc, fn(acc2, char, x) {
      dict.insert(acc2, #(x, y), char)
    })
  })
}

fn find_pois(grid: Dict(Pos, String)) -> Dict(Int, Pos) {
  dict.fold(grid, dict.new(), fn(acc, pos, char) {
    case int.parse(char) {
      Ok(n) -> dict.insert(acc, n, pos)
      _ -> acc
    }
  })
}

// -------------------------------- Explore
pub fn main() -> Nil {
  let param = reader.InputParams(2016, 24)
  let input = reader.read_input(param) |> result.unwrap(or: "")
  solve(input) |> solution.print_solution
  utils.exit(0)
}
