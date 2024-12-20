import aoc/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/priority_queue as queue

pub fn pt_1(input: String) {
  let #(map, start, end) = parse(input)

  let scores = dict.from_list([#(#(start, East), 0)])
  let queue =
    queue.new(fn(a: #(Position, Direction, Int), b) { int.compare(a.2, b.2) })
    |> queue.push(#(start, East, 0))

  find_paths(map, queue, scores, dict.new(), end, #(
    set.new(),
    1_000_000_000_000,
  ))
  |> pair.first
  |> pair.second
}

fn find_paths(
  map,
  queue,
  scores: Dict(#(Position, Direction), Int),
  prev: Dict(#(Position, Direction), Set(#(Position, Direction))),
  target,
  end: #(Set(#(Position, Direction)), Int),
) {
  case queue.pop(queue) {
    Error(_) -> #(end, prev)
    Ok(#(#(position, direction, score), queue)) ->
      case position == target {
        True -> {
          let old_score = end.1
          let previous_positions =
            utils.unwrap(dict.get(prev, #(position, direction)))
          case score < old_score {
            False -> find_paths(map, queue, scores, prev, target, end)
            True ->
              find_paths(map, queue, scores, prev, target, #(
                set.union(previous_positions, end.0),
                score,
              ))
          }
        }
        False -> {
          let Surroundings(left:, right:, forward:) =
            surroundings(map, position, direction)

          let #(queue, scores, prev) = case left {
            None -> #(queue, scores, prev)
            Some(new_direction) -> {
              let score = score + 1000
              let old_score =
                result.unwrap(
                  dict.get(scores, #(position, new_direction)),
                  1_000_000_000_000,
                )
              case score < old_score, score == old_score {
                False, False -> #(queue, scores, prev)
                False, True -> #(
                  queue,
                  scores,
                  dict.upsert(prev, #(position, new_direction), fn(prev) {
                    case prev {
                      Some(prev) -> set.insert(prev, #(position, direction))
                      None -> set.from_list([#(position, direction)])
                    }
                  }),
                )
                True, _ -> #(
                  queue.push(queue, #(position, new_direction, score)),
                  dict.insert(scores, #(position, new_direction), score),
                  dict.insert(
                    prev,
                    #(position, new_direction),
                    set.from_list([#(position, direction)]),
                  ),
                )
              }
            }
          }

          let #(queue, scores, prev) = case right {
            None -> #(queue, scores, prev)
            Some(new_direction) -> {
              let score = score + 1000
              let old_score =
                result.unwrap(
                  dict.get(scores, #(position, new_direction)),
                  1_000_000_000_000,
                )
              case score < old_score, score == old_score {
                False, False -> #(queue, scores, prev)
                False, True -> #(
                  queue,
                  scores,
                  dict.upsert(prev, #(position, new_direction), fn(prev) {
                    case prev {
                      Some(prev) -> set.insert(prev, #(position, direction))
                      None -> set.from_list([#(position, direction)])
                    }
                  }),
                )
                True, _ -> #(
                  queue.push(queue, #(position, new_direction, score)),
                  dict.insert(scores, #(position, new_direction), score),
                  dict.insert(
                    prev,
                    #(position, new_direction),
                    set.from_list([#(position, direction)]),
                  ),
                )
              }
            }
          }

          let #(queue, scores, prev) = case forward {
            False -> #(queue, scores, prev)
            True -> {
              let new_position = move(position, direction)
              let score = score + 1
              let old_score =
                result.unwrap(
                  dict.get(scores, #(new_position, direction)),
                  1_000_000_000_000,
                )
              case score < old_score, score == old_score {
                False, False -> #(queue, scores, prev)
                False, True -> #(
                  queue,
                  scores,
                  dict.upsert(prev, #(new_position, direction), fn(prev) {
                    case prev {
                      Some(prev) -> set.insert(prev, #(position, direction))
                      None -> set.from_list([#(position, direction)])
                    }
                  }),
                )
                True, _ -> #(
                  queue.push(queue, #(new_position, direction, score)),
                  dict.insert(scores, #(new_position, direction), score),
                  dict.insert(
                    prev,
                    #(new_position, direction),
                    set.from_list([#(position, direction)]),
                  ),
                )
              }
            }
          }

          find_paths(map, queue, scores, prev, target, end)
        }
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

  let scores = dict.from_list([#(#(start, East), 0)])
  let queue =
    queue.new(fn(a: #(Position, Direction, Int), b) { int.compare(a.2, b.2) })
    |> queue.push(#(start, East, 0))
  let #(#(back, _), prev) =
    find_paths(map, queue, scores, dict.new(), end, #(
      set.new(),
      1_000_000_000_000,
    ))
  back
  |> set.to_list
  |> list.fold(set.from_list([end]), fn(v, p) { traverse(prev, p, v) })
  |> set.size
}

fn traverse(prev, at: #(Position, Direction), visited) {
  case dict.get(prev, at) {
    Error(_) -> visited
    Ok(previous) -> {
      visited
      |> set.insert(at.0)
      |> list.fold(set.to_list(previous), _, fn(v, p) { traverse(prev, p, v) })
    }
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
