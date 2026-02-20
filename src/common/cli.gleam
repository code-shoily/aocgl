import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import common/reader.{type InputParams, InputParams}

fn year_opt() -> Opt(Int) {
  "year" |> opt.new() |> opt.int |> opt.help("Year")
}

fn day_opt() -> Opt(Int) {
  "day" |> opt.new() |> opt.int |> opt.help("Day")
}

pub fn command() -> Command(InputParams) {
  clip.command({ fn(year) { fn(day) { InputParams(year:, day:) } } })
  |> clip.opt(year_opt())
  |> clip.opt(day_opt())
}

pub fn input_from_cli() -> Result(InputParams, String) {
  command()
  |> clip.help(help.simple(
    "input",
    "[Usage] `gleam run -- --year <year> --day <day>",
  ))
  |> clip.run(argv.load().arguments)
}
