import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn pt_1(input: String) -> Int {
  let state = parse(input)
  find_visited_positions(state) |> set.size
}

fn find_visited_positions(state: State(Position)) -> Set(Position) {
  let new_position = move(state.guard, state.direction)
  case dict.get(state.map, new_position) {
    Error(_) -> state.visited
    Ok(Empty) ->
      find_visited_positions(
        State(
          ..state,
          guard: new_position,
          visited: set.insert(state.visited, new_position),
        ),
      )
    Ok(Obstructed) ->
      find_visited_positions(State(..state, direction: rotate(state.direction)))
  }
}

fn rotate(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn move(position: Position, direction: Direction) -> Position {
  case direction {
    Up -> Position(x: position.x, y: position.y - 1)
    Left -> Position(x: position.x - 1, y: position.y)
    Right -> Position(x: position.x + 1, y: position.y)
    Down -> Position(x: position.x, y: position.y + 1)
  }
}

pub fn pt_2(input: String) -> Int {
  let state = parse(input)
  let visited_directions =
    set.new() |> set.insert(#(state.guard, state.direction))
  detect_loops(state, visited_directions, 0)
}

fn detect_loops(
  state: State(Position),
  visited_directions: Set(#(Position, Direction)),
  count: Int,
) -> Int {
  let new_position = move(state.guard, state.direction)
  case dict.get(state.map, new_position) {
    Error(_) -> count
    Ok(Empty) -> {
      let count = case set.contains(state.visited, new_position) {
        True -> count
        False -> {
          let new_state =
            State(
              ..state,
              map: dict.insert(state.map, new_position, Obstructed),
              visited: visited_directions,
            )
          case detect_loop(new_state) {
            False -> count
            True -> count + 1
          }
        }
      }

      detect_loops(
        State(
          ..state,
          guard: new_position,
          visited: set.insert(state.visited, new_position),
        ),
        set.insert(visited_directions, #(new_position, state.direction)),
        count,
      )
    }
    Ok(Obstructed) ->
      detect_loops(
        State(..state, direction: rotate(state.direction)),
        visited_directions,
        count,
      )
  }
}

fn detect_loop(state: State(#(Position, Direction))) -> Bool {
  let new_position = move(state.guard, state.direction)

  case
    set.contains(state.visited, #(new_position, state.direction)),
    dict.get(state.map, new_position)
  {
    _, Error(_) -> False
    True, _ -> True
    _, Ok(Empty) ->
      detect_loop(
        State(
          ..state,
          guard: new_position,
          visited: set.insert(state.visited, #(new_position, state.direction)),
        ),
      )
    _, Ok(Obstructed) ->
      detect_loop(State(..state, direction: rotate(state.direction)))
  }
}

fn parse(input: String) -> State(Position) {
  use state, line, y <- list.index_fold(
    string.split(input, "\n"),
    State(
      map: dict.new(),
      guard: Position(0, 0),
      visited: set.new(),
      direction: Up,
    ),
  )
  use state, place, x <- list.index_fold(string.to_graphemes(line), state)
  case place {
    "." -> State(..state, map: dict.insert(state.map, Position(x:, y:), Empty))
    "#" ->
      State(..state, map: dict.insert(state.map, Position(x:, y:), Obstructed))
    "^" ->
      State(
        ..state,
        map: dict.insert(state.map, Position(x:, y:), Empty),
        guard: Position(x:, y:),
        visited: set.insert(state.visited, Position(x:, y:)),
      )
    _ -> panic
  }
}

type Place {
  Empty
  Obstructed
}

type Position {
  Position(x: Int, y: Int)
}

type Direction {
  Up
  Down
  Left
  Right
}

type State(visited) {
  State(
    map: Dict(Position, Place),
    guard: Position,
    direction: Direction,
    visited: Set(visited),
  )
}
