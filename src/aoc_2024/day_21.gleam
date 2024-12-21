import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import rememo/memo

pub fn pt_1(input: String) -> Int {
  let codes = parse(input)
  let controllers = controllers(2)
  use cache <- memo.create
  codes
  |> list.map(fn(code) {
    code.number * presses(code.buttons, controllers, cache).0
  })
  |> int.sum
}

fn presses(
  code: List(String),
  controllers: List(Controller),
  cache,
) -> #(Int, List(Controller)) {
  use <- memo.memoize(cache, #(code, controllers))
  use #(count, controllers), button <- list.fold(code, #(0, controllers))
  case controllers {
    [Human] -> #(count + 1, controllers)
    [Robot(keypad:, position:), ..controllers] -> {
      let assert Ok(new_position) = dict.get(keypad, button)
      let assert Ok(blank) = dict.get(keypad, "BLANK")
      let moves = moves(position, new_position, blank)

      let #(new_count, controllers) = solve_solution(moves, controllers, cache)
      #(count + new_count, [
        Robot(keypad:, position: new_position),
        ..controllers
      ])
    }
    _ -> panic
  }
}

fn moves(from: Position, to: Position, blank: Position) -> Solution {
  let dx = to.0 - from.0
  let x_moves = case dx < 0 {
    True -> list.repeat("<", -dx)
    False -> list.repeat(">", dx)
  }
  let dy = to.1 - from.1

  let y_moves = case dy < 0 {
    True -> list.repeat("^", -dy)
    False -> list.repeat("v", dy)
  }

  case #(from.0 + dx, from.1) == blank || dx == 0 {
    True -> Single(list.flatten([y_moves, x_moves, ["A"]]))
    False ->
      case #(from.0, from.1 + dy) == blank || dy == 0 {
        True -> Single(list.flatten([x_moves, y_moves, ["A"]]))
        False ->
          Either(
            list.flatten([x_moves, y_moves, ["A"]]),
            list.flatten([y_moves, x_moves, ["A"]]),
          )
      }
  }
}

type Solution {
  Single(List(String))
  Either(List(String), List(String))
}

fn solve_solution(
  solution: Solution,
  controllers: List(Controller),
  cache,
) -> #(Int, List(Controller)) {
  case solution {
    Single(solution) -> presses(solution, controllers, cache)
    Either(a, b) -> {
      let #(score_a, controllers_a) = presses(a, controllers, cache)
      let #(score_b, controllers_b) = presses(b, controllers, cache)
      case score_a < score_b {
        True -> #(score_a, controllers_a)
        False -> #(score_b, controllers_b)
      }
    }
  }
}

fn directional_keypad() -> Dict(String, Position) {
  dict.from_list([
    #("BLANK", #(0, 0)),
    #("^", #(1, 0)),
    #("A", #(2, 0)),
    #("<", #(0, 1)),
    #("v", #(1, 1)),
    #(">", #(2, 1)),
  ])
}

fn number_keypad() -> Dict(String, Position) {
  dict.from_list([
    #("7", #(0, 0)),
    #("8", #(1, 0)),
    #("9", #(2, 0)),
    #("4", #(0, 1)),
    #("5", #(1, 1)),
    #("6", #(2, 1)),
    #("1", #(0, 2)),
    #("2", #(1, 2)),
    #("3", #(2, 2)),
    #("BLANK", #(0, 3)),
    #("0", #(1, 3)),
    #("A", #(2, 3)),
  ])
}

fn robot(keypad: Dict(String, Position)) -> Controller {
  let assert Ok(position) = dict.get(keypad, "A")
  Robot(keypad:, position:)
}

fn controllers(directional_robots: Int) -> List(Controller) {
  list.flatten([
    [robot(number_keypad())],
    list.repeat(robot(directional_keypad()), directional_robots),
    [Human],
  ])
}

pub fn pt_2(input: String) -> Int {
  let codes = parse(input)
  let controllers = controllers(25)
  use cache <- memo.create
  codes
  |> list.map(fn(code) {
    code.number * presses(code.buttons, controllers, cache).0
  })
  |> int.sum
}

fn parse(input: String) -> List(Code) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(number) = line |> string.drop_end(1) |> int.parse
    Code(buttons: string.to_graphemes(line), number:)
  })
}

type Code {
  Code(buttons: List(String), number: Int)
}

type Position =
  #(Int, Int)

type Controller {
  Robot(keypad: Dict(String, Position), position: Position)
  Human
}
