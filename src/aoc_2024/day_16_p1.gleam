import aoc/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/string
import gleamy/priority_queue as queue

pub fn pt_1(input: String) {
  let #(map, start, end) = parse(input)

  let scores =
    dict.map_values(map, fn(position, _) {
      case position == start {
        True -> 0
        False -> 1_000_000_000_000_000_000
      }
    })
  let queue =
    queue.new(fn(a: #(Position, Direction, Int), b) { int.compare(a.2, b.2) })
    |> queue.push(#(start, East, 0))
  find_paths(map, queue, scores, dict.new())
  |> pair.first
  |> dict.get(end)
  |> utils.unwrap
}

fn find_paths(map, queue, scores, prev) {
  case queue.pop(queue) {
    Error(_) -> #(scores, prev)
    Ok(#(#(position, direction, score), queue)) -> {
      let Surroundings(left:, right:, forward:) =
        surroundings(map, position, direction)

      let #(queue, scores, prev) = case left {
        None -> #(queue, scores, prev)
        Some(direction) -> {
          let new_position = move(position, direction)
          let score = score + 1001
          case score < utils.unwrap(dict.get(scores, new_position)) {
            False -> #(queue, scores, prev)
            True -> #(
              queue.push(queue, #(new_position, direction, score)),
              dict.insert(scores, new_position, score),
              dict.insert(prev, new_position, position),
            )
          }
        }
      }

      let #(queue, scores, prev) = case right {
        None -> #(queue, scores, prev)
        Some(direction) -> {
          let new_position = move(position, direction)
          let score = score + 1001
          case score < utils.unwrap(dict.get(scores, new_position)) {
            False -> #(queue, scores, prev)
            True -> #(
              queue.push(queue, #(new_position, direction, score)),
              dict.insert(scores, new_position, score),
              dict.insert(prev, new_position, position),
            )
          }
        }
      }

      let #(queue, scores, prev) = case forward {
        False -> #(queue, scores, prev)
        True -> {
          let new_position = move(position, direction)
          let score = score + 1
          case score < utils.unwrap(dict.get(scores, new_position)) {
            False -> #(queue, scores, prev)
            True -> #(
              queue.push(queue, #(new_position, direction, score)),
              dict.insert(scores, new_position, score),
              dict.insert(prev, new_position, position),
            )
          }
        }
      }

      find_paths(map, queue, scores, prev)
    }
  }
}

fn surroundings(map, position, direction) {
  let forward = case dict.get(map, move(position, direction)) {
    Ok(Empty) -> True
    _ -> False
  }

  let left = left(direction)
  let left = case dict.get(map, move(position, left)) {
    Ok(Empty) -> Some(left)
    _ -> None
  }

  let right = right(direction)
  let right = case dict.get(map, move(position, right)) {
    Ok(Empty) -> Some(right)
    _ -> None
  }

  Surroundings(left:, right:, forward:)
}

fn move(position: Position, direction) {
  case direction {
    North -> Position(x: position.x, y: position.y - 1)
    East -> Position(x: position.x + 1, y: position.y)
    South -> Position(x: position.x, y: position.y + 1)
    West -> Position(x: position.x - 1, y: position.y)
  }
}

fn left(direction) {
  case direction {
    North -> West
    East -> North
    South -> East
    West -> South
  }
}

fn right(direction) {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

type Surroundings {
  Surroundings(left: Option(Direction), right: Option(Direction), forward: Bool)
}

pub fn pt_2(input: String) {
  let #(map, start, end) = parse(input)

  let scores =
    dict.map_values(map, fn(position, _) {
      case position == start {
        True -> 0
        False -> 1_000_000_000_000_000_000
      }
    })
  let queue =
    queue.new(fn(a: #(Position, Direction, Int), b) { int.compare(a.2, b.2) })
    |> queue.push(#(start, East, 0))
  find_paths(map, queue, scores, dict.new())
  |> pair.second
  |> traverse(end, 0)
}

fn traverse(prev, at, count) {
  case dict.get(prev, at) {
    Error(_) -> count
    Ok(previous) -> traverse(prev, previous, count + 1)
  }
}

fn parse(input: String) {
  use acc, line, y <- list.index_fold(string.split(input, "\n"), #(
    dict.new(),
    Position(0, 0),
    Position(0, 0),
  ))
  use #(map, start, end), char, x <- list.index_fold(
    string.to_graphemes(line),
    acc,
  )
  let position = Position(x:, y:)
  case char {
    "#" -> #(dict.insert(map, position, Wall), start, end)
    "." -> #(dict.insert(map, position, Empty), start, end)
    "E" -> #(dict.insert(map, position, Empty), start, position)
    "S" -> #(dict.insert(map, position, Empty), position, end)
    _ -> panic
  }
}

type Position {
  Position(x: Int, y: Int)
}

type Direction {
  North
  East
  South
  West
}

type Tile {
  Wall
  Empty
}
