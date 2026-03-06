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
import yog/model.{Graph}
import yog/pathfinding

pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

const infinity = 999_999_999

fn solve_part_1(input: #(Dict(#(Int, Int), Int), Int)) -> Int {
  let #(distances, poi_count) = input
  let targets = utils.int_range(1, poi_count - 1)

  list.permutations(targets)
  |> list.map(fn(p) { calculate_path_dist(distances, [0, ..p]) })
  |> list.fold(infinity, int.min)
}

fn solve_part_2(input: #(Dict(#(Int, Int), Int), Int)) -> Int {
  let #(distances, poi_count) = input

  let targets = utils.int_range(1, poi_count - 1)

  list.permutations(targets)
  |> list.map(fn(p) {
    let path = list.flatten([[0], p, [0]])
    calculate_path_dist(distances, path)
  })
  |> list.fold(infinity, int.min)
}

fn calculate_path_dist(
  distances: Dict(#(Int, Int), Int),
  path: List(Int),
) -> Int {
  let pairs = list.window_by_2(path)

  use dist, #(a, b) <- list.fold(pairs, 0)

  let pair = case a < b {
    True -> #(a, b)
    False -> #(b, a)
  }

  let assert Ok(cur) = dict.get(distances, pair)
  dist + cur
}

fn parse(raw_input: String) {
  let Graph(_, nodes, _, _) as graph =
    raw_input
    |> utils.to_lines()
    |> list.map(string.to_graphemes)
    |> grid.from_2d_list(model.Undirected, can_move: grid.avoiding("#"))
    |> grid.to_graph()

  let pois = {
    use acc, id, char <- dict.fold(nodes, dict.new())
    case int.parse(char) {
      Ok(label) -> dict.insert(acc, label, id)
      _ -> acc
    }
  }

  let poi_dist = {
    use acc_1, label_1, id_1 <- dict.fold(pois, dict.new())

    let distances =
      pathfinding.single_source_distances(
        in: graph,
        from: id_1,
        with_zero: 0,
        with_add: int.add,
        with_compare: int.compare,
      )

    use acc_2, label_2, id_2 <- dict.fold(pois, acc_1)

    let assert Ok(dist) = dict.get(distances, id_2)
    dict.insert(acc_2, #(label_1, label_2), dist)
  }

  #(poi_dist, dict.size(pois))
}
// -------------------------------- Explore
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2016, 24) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
