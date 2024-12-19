import aoc/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleamy/priority_queue as queue

const size = 71

pub fn pt_1(input: String) {
  let map = input |> parse |> fill_grid(0, 0)

  shortest_path_to_exit(map) |> utils.unwrap
}

fn shortest_path_to_exit(map) {
  let scores = dict.from_list([#(Vector(0, 0), 0)])
  let queue =
    queue.new(fn(a: #(Vector, Int), b) { int.compare(a.1, b.1) })
    |> queue.push(#(Vector(0, 0), 0))

  dijkstra(map, queue, scores)
  |> dict.get(Vector(size - 1, size - 1))
}

fn dijkstra(map, queue, scores) {
  case queue.pop(queue) {
    Error(_) -> scores
    Ok(#(#(position, score), queue)) -> {
      let Surroundings(up:, down:, left:, right:) = surroundings(map, position)
      let #(queue, scores) = case up {
        None -> #(queue, scores)
        Some(position) -> {
          let score = score + 1
          case
            score < result.unwrap(dict.get(scores, position), 10_000_000_000)
          {
            False -> #(queue, scores)
            True -> #(
              queue.push(queue, #(position, score)),
              dict.insert(scores, position, score),
            )
          }
        }
      }

      let #(queue, scores) = case down {
        None -> #(queue, scores)
        Some(position) -> {
          let score = score + 1
          case
            score < result.unwrap(dict.get(scores, position), 10_000_000_000)
          {
            False -> #(queue, scores)
            True -> #(
              queue.push(queue, #(position, score)),
              dict.insert(scores, position, score),
            )
          }
        }
      }

      let #(queue, scores) = case left {
        None -> #(queue, scores)
        Some(position) -> {
          let score = score + 1
          case
            score < result.unwrap(dict.get(scores, position), 10_000_000_000)
          {
            False -> #(queue, scores)
            True -> #(
              queue.push(queue, #(position, score)),
              dict.insert(scores, position, score),
            )
          }
        }
      }

      let #(queue, scores) = case right {
        None -> #(queue, scores)
        Some(position) -> {
          let score = score + 1
          case
            score < result.unwrap(dict.get(scores, position), 10_000_000_000)
          {
            False -> #(queue, scores)
            True -> #(
              queue.push(queue, #(position, score)),
              dict.insert(scores, position, score),
            )
          }
        }
      }

      dijkstra(map, queue, scores)
    }
  }
}

fn surroundings(map, position: Vector) {
  let up = Vector(position.x, position.y - 1)
  let down = Vector(position.x, position.y + 1)
  let left = Vector(position.x - 1, position.y)
  let right = Vector(position.x + 1, position.y)
  let up = case dict.get(map, up) {
    Ok(Open) -> Some(up)
    _ -> None
  }
  let down = case dict.get(map, down) {
    Ok(Open) -> Some(down)
    _ -> None
  }
  let left = case dict.get(map, left) {
    Ok(Open) -> Some(left)
    _ -> None
  }
  let right = case dict.get(map, right) {
    Ok(Open) -> Some(right)
    _ -> None
  }

  Surroundings(up:, down:, left:, right:)
}

type Surroundings {
  Surroundings(
    up: Option(Vector),
    down: Option(Vector),
    left: Option(Vector),
    right: Option(Vector),
  )
}

pub fn pt_2(input: String) {
  let position = do_the_thing(parse2(input), fill_grid(dict.new(), 0, 0))
  int.to_string(position.x) <> "," <> int.to_string(position.y)
}

fn do_the_thing(bytes, map) {
  let assert [blocked, ..bytes] = bytes
  let map = dict.insert(map, blocked, Blocked)
  case shortest_path_to_exit(map) {
    Error(_) -> blocked
    Ok(_) -> do_the_thing(bytes, map)
  }
}

fn parse(input) {
  use map, pair <- list.fold(
    string.split(input, "\n") |> list.take(1024),
    dict.new(),
  )
  let assert Ok(#(x, y)) = string.split_once(pair, ",")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  dict.insert(map, Vector(x, y), Blocked)
}

fn parse2(input) {
  use pair <- list.map(string.split(input, "\n"))
  let assert Ok(#(x, y)) = string.split_once(pair, ",")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x, y)
}

fn fill_grid(map, x, y) {
  case x >= size, y >= size {
    _, True -> map
    True, False -> fill_grid(map, 0, y + 1)
    False, False ->
      case dict.has_key(map, Vector(x:, y:)) {
        False -> dict.insert(map, Vector(x:, y:), Open)
        True -> map
      }
      |> fill_grid(x + 1, y)
  }
}

type Vector {
  Vector(x: Int, y: Int)
}

type Tile {
  Open
  Blocked
}
