/// Title: Air Duct Spelunking
/// Link: https://adventofcode.com/2016/day/24
/// Difficulty: l
/// Tags: graph grid shortest-path tsp
import common/solution.{type Solution, OfInt, Solution}
import common/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import yog/builder/grid
import yog/model
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
  let grid_data = list.map(lines, string.to_graphemes)

  let grid_obj =
    grid.from_2d_list(grid_data, model.Undirected, can_move: fn(from, to) {
      from != "#" && to != "#"
    })

  let graph = grid.to_graph(grid_obj)

  let pois =
    dict.fold(graph.nodes, dict.new(), fn(acc, id, char) {
      case int.parse(char) {
        Ok(n) -> dict.insert(acc, n, id)
        _ -> acc
      }
    })

  let poi_dist =
    dict.fold(pois, dict.new(), fn(acc, label_a, id_a) {
      let distances =
        pathfinding.single_source_distances(
          in: graph,
          from: id_a,
          with_zero: 0,
          with_add: int.add,
          with_compare: int.compare,
        )

      dict.fold(pois, acc, fn(acc2, label_b, id_b) {
        let assert Ok(dist) = dict.get(distances, id_b)
        dict.insert(acc2, #(label_a, label_b), dist)
      })
    })

  Input(poi_dist, dict.size(pois))
}
// -------------------------------- Explore
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2016, 24) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
