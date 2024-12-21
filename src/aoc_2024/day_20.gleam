import aoc/utils
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleamy/priority_queue as queue

pub fn pt_1(input: String) {
  let #(map, start, end) = parse(input)
  let base = a_star(start, end, map)
  let obstacles = map |> dict.filter(fn(_, tile) { tile == Wall }) |> dict.keys
  list.filter_map(obstacles, fn(obstacle) {
    let map = dict.insert(map, obstacle, Track)
    let diff = base - a_star(start, end, map)
    case diff {
      0 -> Error(Nil)
      _ -> Ok(diff)
    }
  })
  |> list.count(fn(a) { a >= 100 })
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

fn parse(input) {
  use acc, line, y <- list.index_fold(
    string.split(input, "\n"),
    #(dict.new(), #(0, 0), #(0, 0)),
  )
  use #(map, start, end), char, x <- list.index_fold(
    string.to_graphemes(line),
    acc,
  )
  let position = #(x, y)
  case char {
    "." -> #(dict.insert(map, position, Track), start, end)
    "#" -> #(dict.insert(map, position, Wall), start, end)
    "S" -> #(dict.insert(map, position, Track), position, end)
    "E" -> #(dict.insert(map, position, Track), start, position)
    _ -> panic
  }
}

fn a_star(start, end: #(Int, Int), map) {
  let h = fn(p: #(Int, Int)) {
    int.absolute_value(p.0 - end.0) + int.absolute_value(p.1 - end.1)
  }
  let open_set =
    queue.new(fn(a: #(#(Int, Int), Int), b) { int.compare(a.1, b.1) })
    |> queue.push(#(start, h(start)))
  let g_scores = dict.from_list([#(start, 0)])
  let f_scores = dict.from_list([#(start, h(start))])
  do_a_star(open_set, g_scores, f_scores, end, map, h)
}

fn do_a_star(open_set, g_scores, f_scores, goal, map, h) {
  case queue.pop(open_set) {
    Error(_) -> panic
    Ok(#(#(current, _), open_set)) -> {
      case current == goal {
        True -> dict.get(g_scores, current) |> utils.unwrap
        False -> {
          let #(open_set, g_scores, f_scores) =
            list.fold(
              neighbours(current, map),
              #(open_set, g_scores, f_scores),
              fn(acc, neighbour) {
                let #(open_set, g_scores, f_scores) = acc
                let assert Ok(g_score) = dict.get(g_scores, current)
                let tentative = g_score + 1
                let neighbour_score =
                  dict.get(g_scores, neighbour) |> result.unwrap(1_000_000_000)
                case tentative < neighbour_score {
                  True -> #(
                    case
                      open_set
                      |> queue.to_list
                      |> list.any(fn(p) { p.0 == neighbour })
                    {
                      False ->
                        queue.push(open_set, #(
                          neighbour,
                          tentative + h(neighbour),
                        ))
                      True -> open_set
                    },
                    dict.insert(g_scores, neighbour, tentative),
                    dict.insert(f_scores, neighbour, tentative + h(neighbour)),
                  )
                  False -> acc
                }
              },
            )
          do_a_star(open_set, g_scores, f_scores, goal, map, h)
        }
      }
    }
  }
}

fn neighbours(position, map) {
  let #(x, y) = position
  let neighbours = []
  let neighbours = case dict.get(map, #(x + 1, y)) {
    Ok(Track) -> [#(x + 1, y), ..neighbours]
    _ -> neighbours
  }
  let neighbours = case dict.get(map, #(x - 1, y)) {
    Ok(Track) -> [#(x - 1, y), ..neighbours]
    _ -> neighbours
  }
  let neighbours = case dict.get(map, #(x, y + 1)) {
    Ok(Track) -> [#(x, y + 1), ..neighbours]
    _ -> neighbours
  }
  let neighbours = case dict.get(map, #(x, y - 1)) {
    Ok(Track) -> [#(x, y - 1), ..neighbours]
    _ -> neighbours
  }
  neighbours
}

type Tile {
  Track
  Wall
}
