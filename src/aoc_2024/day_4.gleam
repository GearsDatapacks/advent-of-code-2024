import gleam/bool
import gleam/dict
import gleam/list
import gleam/string

pub fn pt_1(inputs: String) -> Int {
  let grid = parse(inputs)
  use count, #(x, y), char <- dict.fold(grid, 0)

  case char {
    "X" -> count + search(grid, x, y)
    _ -> count
  }
}

fn search(grid, x, y) {
  [#(1, 0), #(-1, 0), #(0, 1), #(0, -1), #(1, 1), #(1, -1), #(-1, 1), #(-1, -1)]
  |> list.count(fn(direction) {
    check_direction(grid, x, y, direction.0, direction.1)
  })
}

fn check_direction(grid, x, y, dx, dy) {
  use <- bool.guard(dict.get(grid, #(x + dx, y + dy)) != Ok("M"), False)
  use <- bool.guard(dict.get(grid, #(x + dx * 2, y + dy * 2)) != Ok("A"), False)
  dict.get(grid, #(x + dx * 3, y + dy * 3)) == Ok("S")
}

fn parse(inputs: String) {
  inputs
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.split("")
    |> list.index_map(fn(char, x) { #(#(x, y), char) })
  })
  |> list.flatten
  |> dict.from_list
}

pub fn pt_2(inputs: String) -> Int {
  let grid = parse(inputs)
  use count, #(x, y), char <- dict.fold(grid, 0)

  case char {
    "A" ->
      case check_x_mas(grid, x, y) {
        False -> count
        True -> count + 1
      }
    _ -> count
  }
}

fn check_x_mas(grid, x, y) {
  case dict.get(grid, #(x - 1, y - 1)), dict.get(grid, #(x + 1, y + 1)) {
    Ok("M"), Ok("S") | Ok("S"), Ok("M") ->
      case dict.get(grid, #(x + 1, y - 1)), dict.get(grid, #(x - 1, y + 1)) {
        Ok("M"), Ok("S") | Ok("S"), Ok("M") -> True
        _, _ -> False
      }

    _, _ -> False
  }
}
