import common/reader.{InputParams}
import common/solution.{NotDone}
import common/utils
import gleam/float
import gleam/int
import gleam/io
import gleam/list

@external(erlang, "os", "timestamp")
fn timestamp() -> #(Int, Int, Int)

fn to_micros(t: #(Int, Int, Int)) -> Int {
  let #(mega, sec, micro) = t
  mega * 1_000_000_000_000 + sec * 1_000_000 + micro
}

pub fn main() {
  io.println("year,day,time_ms")

  let years = [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025]
  let days = utils.int_range(1, 25)

  list.each(years, fn(year) {
    list.each(days, fn(day) {
      let params = InputParams(year, day)
      case reader.read_input(params) {
        Ok(input) -> {
          let start = timestamp() |> to_micros
          let res = case year {
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
            _ -> Error(NotDone)
          }

          case res {
            Ok(_) -> {
              let end = timestamp() |> to_micros
              let elapsed = int.to_float(end - start) /. 1000.0
              io.println(
                int.to_string(year)
                <> ","
                <> int.to_string(day)
                <> ","
                <> float.to_string(elapsed),
              )
            }
            _ -> Nil
          }
        }
        _ -> Nil
      }
    })
  })
}

// We need to import the runners
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
