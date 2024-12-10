import gleam/dict
import gleam/int
import gleam/list
import gleam/set
import gleam/string

pub fn pt_1(input: String) {
  let map = parse(input)
  use count, position, _ <- dict.fold(map, 0)
  count + set.size(search(map, position, 0, set.new()))
}

fn search(map, position: Position, expect: Int, visited) {
  case dict.get(map, position) {
    Ok(9) if expect == 9 -> set.insert(visited, position)
    Ok(value) if value == expect -> {
      list.fold(directions(position), visited, fn(visited, position) {
        search(map, position, expect + 1, visited)
      })
    }
    _ -> visited
  }
}

pub fn pt_2(input: String) {
  let map = parse(input)
  use count, position, _ <- dict.fold(map, 0)
  count + search2(map, position, 0)
}

fn search2(map, position: Position, expect: Int) {
  case dict.get(map, position) {
    Ok(9) if expect == 9 -> 1
    Ok(value) if value == expect -> {
      list.fold(directions(position), 0, fn(acc, position) {
        acc + search2(map, position, expect + 1)
      })
    }
    _ -> 0
  }
}

fn parse(input) {
  use map, line, y <- list.index_fold(string.split(input, "\n"), dict.new())
  use map, char, x <- list.index_fold(string.to_graphemes(line), map)
  let assert Ok(height) = int.parse(char)
  dict.insert(map, Position(x:, y:), height)
}

type Position {
  Position(x: Int, y: Int)
}

fn directions(position: Position) {
  [
    Position(x: position.x + 1, y: position.y),
    Position(x: position.x - 1, y: position.y),
    Position(x: position.x, y: position.y + 1),
    Position(x: position.x, y: position.y - 1),
  ]
}
