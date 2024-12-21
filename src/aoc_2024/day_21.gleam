import rememo/memo
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub fn pt_1(input: String) {
  let codes = parse(input)
  let controllers = controllers()
  use cache <- memo.create
  codes
  |> list.map(fn(code) { code.number * presses(code.buttons, controllers, cache).0 })
  |> int.sum
}

fn presses(code, controllers, cache) {
  use <- memo.memoize(cache, #(code, controllers))
  use #(count, controllers), button <- list.fold(code, #(0, controllers))
  case controllers {
    [Human] -> #(count + 1, controllers)
    [Robot(keypad:, position:), ..controllers] -> {
      let assert Ok(new_position) = dict.get(keypad, button)
      let moves = moves(position, new_position, keypad)

      let #(new_count, controllers) =
        moves
        |> map(presses(_, controllers, cache))
        |> min(fn(a: #(Int, List(Controller)), b) { int.compare(a.0, b.0) })
      #(count + new_count, [
        Robot(keypad:, position: new_position),
        ..controllers
      ])
    }
    _ -> panic
  }
}

type Order {
  Xy
  Yx
  Any
}

fn moves(
  from: Position,
  to: Position,
  keypad: Dict(String, Position),
) -> OneOrTwo(List(String)) {
  let assert Ok(blank) = dict.get(keypad, "BLANK")
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

  let order = case #(from.0 + dx, from.1) == blank || dx == 0 {
    True -> Yx
    False ->
      case #(from.0, from.1 + dy) == blank || dy == 0 {
        True -> Xy
        False -> Any
      }
  }

  let moves = case order {
    Xy -> One(list.append(x_moves, y_moves))
    Yx -> One(list.append(y_moves, x_moves))
    Any -> {
      Two(list.append(x_moves, y_moves), list.append(y_moves, x_moves))
    }
  }

  map(moves, list.append(_, ["A"]))
}

type OneOrTwo(a) {
  One(a)
  Two(a, a)
}

fn map(oot, f) {
  case oot {
    One(value) -> One(f(value))
    Two(a, b) -> Two(f(a), f(b))
  }
}

fn min(oot, f) {
  case oot {
    One(value) -> value
    Two(a, b) ->
      case f(a, b) {
        order.Lt -> a
        _ -> b
      }
  }
}

fn directional_keypad() {
  dict.from_list([
    #("BLANK", #(0, 0)),
    #("^", #(1, 0)),
    #("A", #(2, 0)),
    #("<", #(0, 1)),
    #("v", #(1, 1)),
    #(">", #(2, 1)),
  ])
}

fn number_keypad() {
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

fn robot(keypad) {
  let assert Ok(position) = dict.get(keypad, "A")
  Robot(keypad:, position:)
}

fn controllers() {
  [
    robot(number_keypad()),
    robot(directional_keypad()),
    robot(directional_keypad()),
    Human,
  ]
}

fn controllers2() {
  list.flatten([
    [robot(number_keypad())],
    list.repeat(robot(directional_keypad()), 25),
    [Human],
  ])
}

pub fn pt_2(input: String) {
  let codes = parse(input)
  let controllers = controllers2()
  use cache <- memo.create
  codes
  |> list.map(fn(code) { code.number * presses(code.buttons, controllers, cache).0 })
  |> int.sum
}

fn parse(input) {
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
