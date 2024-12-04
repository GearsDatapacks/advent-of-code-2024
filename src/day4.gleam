import gleam/bool
import gleam/dict
import gleam/list
import gleam/string

pub fn part1(inputs: String) -> Int {
  let #(grid, grid_size) = parse(inputs)

  do_part1(grid, grid_size, 0, 0, 0)
}

fn do_part1(grid, grid_size, x, y, count) {
  use <- bool.guard(y >= grid_size, count)

  let assert Ok(char) = dict.get(grid, #(x, y))
  let #(next_x, next_y) = case x >= grid_size - 1 {
    False -> #(x + 1, y)
    True -> #(0, y + 1)
  }

  case char {
    "X" -> {
      let count = count + search1(grid, x, y)
      do_part1(grid, grid_size, next_x, next_y, count)
    }
    _ -> do_part1(grid, grid_size, next_x, next_y, count)
  }
}

fn search1(grid, x, y) {
  [#(1, 0), #(-1, 0), #(0, 1), #(0, -1), #(1, 1), #(1, -1), #(-1, 1), #(-1, -1)]
  |> list.filter(fn(direction) {
    check_direction(grid, x, y, direction.0, direction.1)
  })
  |> list.length
}

fn check_direction(grid, x, y, dx, dy) {
  use <- bool.guard(dict.get(grid, #(x + dx, y + dy)) != Ok("M"), False)
  use <- bool.guard(dict.get(grid, #(x + dx * 2, y + dy * 2)) != Ok("A"), False)
  dict.get(grid, #(x + dx * 3, y + dy * 3)) == Ok("S")
}

fn parse(inputs: String) {
  let rows =
    inputs
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.split("")
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })

  let grid =
    rows
    |> list.flatten
    |> dict.from_list
  #(grid, list.length(rows))
}

pub fn part2(inputs: String) -> Int {
  let #(grid, grid_size) = parse(inputs)

  do_part2(grid, grid_size, 0, 0, 0)
}

fn do_part2(grid, grid_size, x, y, count) {
  use <- bool.guard(y >= grid_size, count)

  let assert Ok(char) = dict.get(grid, #(x, y))
  let #(next_x, next_y) = case x >= grid_size - 1 {
    False -> #(x + 1, y)
    True -> #(0, y + 1)
  }

  case char {
    "A" -> {
      let count = case check_x_mas(grid, x, y) {
        False -> count
        True -> count + 1
      }
      do_part2(grid, grid_size, next_x, next_y, count)
    }
    _ -> do_part2(grid, grid_size, next_x, next_y, count)
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
