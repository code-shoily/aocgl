# aocgl

Advent of Code solutions written in Gleam.

## Features

- Solutions for Advent of Code puzzles from 2015-2025
- Automatic scaffolding tool to generate solution skeletons
- Automatic input fetching from Advent of Code (with session key)
- Organized project structure with tests

## Getting Started

### Prerequisites

- [Gleam](https://gleam.run/) installed
- An Advent of Code account (for fetching inputs)

### Installation

```sh
gleam deps download
```

### Setting up AOC Session Key (Optional)

To automatically fetch puzzle inputs, you need to set your Advent of Code session key:

1. Log in to [Advent of Code](https://adventofcode.com/)
2. Open browser DevTools (F12)
3. Go to Application/Storage > Cookies
4. Copy the value of the `session` cookie
5. Set the environment variable:

```sh
export AOC_SESSION_KEY=your_session_key_here
```

Without this key, the scaffold tool will create an empty input file that you'll need to fill manually.

## Usage

### Running Solutions

Run a specific day's solution:

```sh
gleam run -- <year> <day>
```

Examples:
```sh
gleam run -- 2024 1      # Run 2024 Day 1
gleam run -- 2023 25     # Run 2023 Day 25
```

### Scaffolding a New Solution

Generate the boilerplate for a new day:

```sh
gleam run -m scripts/scaffold -- <year> <day>
```

Examples:
```sh
gleam run -m scripts/scaffold -- 2024 1
gleam run -m scripts/scaffold -- 2023 15
```

This will create:
- `src/year_YYYY/day_DD.gleam` - Solution module with template code
- `test/year_YYYY/day_DD_test.gleam` - Test module
- `inputs/YYYY_DD.txt` - Input file (auto-fetched if AOC_SESSION_KEY is set)

The scaffold tool will:
- Create necessary directories if they don't exist
- Skip files that already exist (safe to re-run)
- Fetch your personal puzzle input from adventofcode.com (if session key is provided)

### Running Tests

```sh
gleam test                    # Run all tests
gleam test -- year_2024       # Run tests for specific year
```

## Project Structure

```
aocgl/
├── src/
│   ├── aocgl.gleam           # Main entry point
│   ├── common/               # Shared utilities
│   ├── scripts/
│   │   └── scaffold.gleam    # Scaffolding tool
│   └── year_YYYY/            # Solutions by year
│       ├── runner.gleam      # Year-specific router
│       └── day_DD.gleam      # Individual day solutions
├── test/
│   └── year_YYYY/
│       └── day_DD_test.gleam # Tests for each day
└── inputs/
    └── YYYY_DD.txt           # Puzzle inputs
```

## Solution Template

Each scaffolded solution follows this structure:

```gleam
pub fn solve(raw_input: String) -> Solution {
  let input = parse(raw_input)
  let part_1 = solve_part_1(input) |> OfInt
  let part_2 = solve_part_2(input) |> OfInt

  Solution(part_1, part_2)
}

fn solve_part_1(input: List(Int)) -> Int {
  // Implement part 1 solution
  input |> list.length()
}

fn solve_part_2(input: List(Int)) -> Int {
  // Implement part 2 solution
  input |> list.length()
}

fn parse(raw_input: String) -> List(Int) {
  // Parse input into desired format
}
```

## Development

```sh
gleam run      # Run the project
gleam test     # Run the tests
gleam build    # Build the project
```

## Contributing

Feel free to explore different approaches and optimizations for the solutions!

## License

This project is for educational purposes and personal development.
