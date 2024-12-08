import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

pub fn pt_1(input: String) -> Int {
  input
  |> parse
  |> find_antinodes
  |> set.size
}

fn find_antinodes(map: Map) -> set.Set(Vector) {
  use antinodes, _, antennae <- dict.fold(map.antennae, set.new())
  use antinodes, #(a, b) <- list.fold(
    list.combination_pairs(antennae),
    antinodes,
  )

  let distance = subtract(b, a)
  let antinode1 = add(b, distance)
  let antinode2 = subtract(a, distance)
  let antinodes = case within_bounds(antinode1, map.width, map.height) {
    False -> antinodes
    True -> set.insert(antinodes, antinode1)
  }
  case within_bounds(antinode2, map.width, map.height) {
    False -> antinodes
    True -> set.insert(antinodes, antinode2)
  }
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse
  |> find_antinodes2
  |> set.size
}

fn find_antinodes2(map: Map) -> set.Set(Vector) {
  use antinodes, _, antennae <- dict.fold(map.antennae, set.new())
  use antinodes, #(a, b) <- list.fold(
    list.combination_pairs(antennae),
    antinodes,
  )
  let antinodes =
    trace_line(b, subtract(b, a), antinodes, map.width, map.height)
  trace_line(a, subtract(a, b), antinodes, map.width, map.height)
}

fn trace_line(
  position: Vector,
  direction: Vector,
  antinodes: set.Set(Vector),
  width: Int,
  height: Int,
) -> set.Set(Vector) {
  case within_bounds(position, width, height) {
    True ->
      trace_line(
        add(position, direction),
        direction,
        set.insert(antinodes, position),
        width,
        height,
      )
    False -> antinodes
  }
}

type Vector {
  Vector(x: Int, y: Int)
}

fn add(a: Vector, b: Vector) -> Vector {
  Vector(x: a.x + b.x, y: a.y + b.y)
}

fn subtract(a: Vector, b: Vector) -> Vector {
  Vector(x: a.x - b.x, y: a.y - b.y)
}

fn within_bounds(v: Vector, width: Int, height: Int) -> Bool {
  v.x >= 0 && v.x <= width && v.y >= 0 && v.y <= height
}

type Map {
  Map(antennae: dict.Dict(String, List(Vector)), width: Int, height: Int)
}

fn parse(input: String) -> Map {
  use map, line, y <- list.index_fold(
    string.split(input, "\n"),
    Map(antennae: dict.new(), width: 0, height: 0),
  )
  use map, char, x <- list.index_fold(string.to_graphemes(line), map)
  case char {
    "." -> Map(..map, width: x, height: y)
    _ -> {
      let position = Vector(x:, y:)
      let antennae =
        dict.upsert(map.antennae, char, fn(antennae) {
          case antennae {
            None -> [position]
            Some(antennae) -> [position, ..antennae]
          }
        })
      Map(antennae:, width: x, height: y)
    }
  }
}
