import gleam/bool
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

pub fn pt_1(input: String) {
  let #(grid, antennae) = parse(input)

  let antinodes = find_antinodes(grid, antennae)

  set.size(antinodes)
}

fn find_antinodes(grid, antennae) {
  use antinodes, a, place <- dict.fold(grid, set.new())
  case place {
    Empty -> antinodes
    Antenna(frequency) -> {
      let assert Ok(antennae) = dict.get(antennae, frequency)
      use antinodes, b <- list.fold(antennae, antinodes)
      let difference = subtract(b, a)
      use <- bool.guard(difference == Position(0, 0), antinodes)
      let antinode1 = add(b, difference)
      let antinode2 = subtract(a, difference)
      let antinodes = case dict.has_key(grid, antinode1) {
        False -> antinodes
        True -> set.insert(antinodes, antinode1)
      }
      case dict.has_key(grid, antinode2) {
        False -> antinodes
        True -> set.insert(antinodes, antinode2)
      }
    }
  }
}

pub fn pt_2(input: String) {
  let #(grid, antennae) = parse(input)

  let antinodes = find_antinodes2(grid, antennae)

  set.size(antinodes)
}

fn find_antinodes2(grid, antennae) {
  use antinodes, a, place <- dict.fold(grid, set.new())
  case place {
    Empty -> antinodes
    Antenna(frequency) -> {
      let assert Ok(antennae) = dict.get(antennae, frequency)
      use antinodes, b <- list.fold(antennae, antinodes)
      use <- bool.guard(a == b, antinodes)
      let antinodes = trace_line(grid, b, subtract(b, a), antinodes)
      trace_line(grid, a, subtract(a, b), antinodes)
    }
  }
}

fn trace_line(grid, position, direction, antinodes) {
  case dict.has_key(grid, position) {
    True ->
      trace_line(
        grid,
        add(position, direction),
        direction,
        set.insert(antinodes, position),
      )
    False -> antinodes
  }
}

type Place {
  Empty
  Antenna(String)
}

type Position {
  Position(x: Int, y: Int)
}

fn add(a: Position, b: Position) {
  Position(x: a.x + b.x, y: a.y + b.y)
}

fn subtract(a: Position, b: Position) {
  Position(x: a.x - b.x, y: a.y - b.y)
}

fn parse(input: String) {
  use acc, line, y <- list.index_fold(string.split(input, "\n"), #(
    dict.new(),
    dict.new(),
  ))
  use #(grid, antennae), char, x <- list.index_fold(
    string.to_graphemes(line),
    acc,
  )
  let position = Position(x:, y:)
  case char {
    "." -> #(dict.insert(grid, position, Empty), antennae)
    _ -> #(
      dict.insert(grid, position, Antenna(char)),
      dict.upsert(antennae, char, fn(antennae) {
        case antennae {
          None -> [position]
          Some(antennae) -> [position, ..antennae]
        }
      }),
    )
  }
}
