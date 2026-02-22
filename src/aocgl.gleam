import common/cli
import common/reader.{type InputParams, InputParams}
import common/solution.{InvalidYear, NotDone}
import common/utils
import gleam/int
import gleam/io
import gleam/result
import year_2015/runner as runner_2015
import year_2016/runner as runner_2016
import year_2017/runner as runner_2017
import year_2018/runner as runner_2018
import year_2019/runner as runner_2019
import year_2020/runner as runner_2020
import year_2021/runner as runner_2021
import year_2022/runner as runner_2022
import year_2023/runner as runner_2023
import year_2024/runner as runner_2024
import year_2025/runner as runner_2025

pub fn main() -> Nil {
  let result = {
    use params <- result.try(
      cli.input_from_cli() |> result.map_error(fn(e) { e }),
    )
    use input <- result.try(
      reader.read_input(params)
      |> result.map_error(fn(_) { "Failed to read input file." }),
    )

    Ok(print_solution_for(params, input))
  }

  case result {
    Ok(_) -> Nil
    Error(err) -> io.print_error(err)
  }
}

fn print_solution_for(params: InputParams, input: String) {
  let InputParams(year, day) = params

  let maybe_solution = case year {
    2015 -> runner_2015.solve_for(input, day)
    2016 -> runner_2016.solve_for(input, day)
    2017 -> runner_2017.solve_for(input, day)
    2018 -> runner_2018.solve_for(input, day)
    2019 -> runner_2019.solve_for(input, day)
    2020 -> runner_2020.solve_for(input, day)
    2021 -> runner_2021.solve_for(input, day)
    2022 -> runner_2022.solve_for(input, day)
    2023 -> runner_2023.solve_for(input, day)
    2024 -> runner_2024.solve_for(input, day)
    2025 -> runner_2025.solve_for(input, day)
    _ -> Error(InvalidYear)
  }

  case maybe_solution {
    Ok(solution) -> solution.print_solution(solution)
    Error(InvalidYear) ->
      io.print_error("[Logical Error] Invalid Year: " <> int.to_string(year))
    Error(NotDone) ->
      io.print_error(
        "Not implemented: " <> int.to_string(year) <> "/" <> int.to_string(day),
      )
  }

  utils.exit(0)
}
