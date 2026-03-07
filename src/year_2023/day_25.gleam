/// Title: Snowverload
/// Link: https://adventofcode.com/2023/day/25
/// Difficulty: xl
/// Tags: graph min-cut stoer-wagner
import common/solution.{type Solution, OfDay25, OfInt, Solution}
import common/utils
import gleam/list
import gleam/string
import yog/builder/labeled
import yog/min_cut
import yog/model.{type Graph}

pub fn solve(raw_input: String) -> Solution {
  let graph = parse(raw_input)
  let part_1 = solve_part_1(graph) |> OfInt

  Solution(part_1, OfDay25(Nil))
}

fn solve_part_1(graph: Graph(String, Int)) -> Int {
  let result = min_cut.global_min_cut(graph)

  result.group_a_size * result.group_b_size
}

fn parse(raw_input: String) -> Graph(String, Int) {
  labeled.to_graph({
    use builder, line <- list.fold(
      utils.to_lines(raw_input),
      labeled.undirected(),
    )
    case string.split(line, ": ") {
      [source, dests] -> {
        use b, target <- list.fold(string.split(dests, " "), builder)
        labeled.add_edge(b, from: source, to: target, with: 1)
      }
      _ -> builder
    }
  })
}
// ------------------------------ Exploration
// import common/reader.{InputParams}

// pub fn main() -> Nil {
//   let assert Ok(input) = InputParams(2023, 25) |> reader.read_input
//   input |> utils.timed(solve) |> echo

//   utils.exit(0)
// }
