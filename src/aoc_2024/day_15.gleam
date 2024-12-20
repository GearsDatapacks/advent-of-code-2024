import gleam/dict
import gleam/io
import gleam/list
import gleam/string

pub fn pt_1(input: String) -> Int {
  parse(input)
  |> iterate
  |> score
}

fn iterate(warehouse: Warehouse) -> Warehouse {
  case warehouse.moves {
    [] -> warehouse
    [move, ..moves] -> {
      let warehouse = try_move(move, warehouse)
      // print_grid(warehouse, 0, 0, "")
      iterate(Warehouse(..warehouse, moves:))
    }
  }
}

fn try_move(move: Move, warehouse: Warehouse) -> Warehouse {
  case can_move(move, warehouse) {
    False -> warehouse
    True -> {
      let warehouse =
        Warehouse(
          ..warehouse,
          robot_position: move_position(move, warehouse.robot_position),
        )
      do_move(move, warehouse.robot_position, Empty, warehouse)
    }
  }
}

fn move_position(move: Move, p: Position) -> Position {
  case move {
    Down -> Position(r: p.r + 1, c: p.c)
    Up -> Position(r: p.r - 1, c: p.c)
    Right -> Position(r: p.r, c: p.c + 1)
    Left -> Position(r: p.r, c: p.c - 1)
  }
}

const size = 50

fn print_grid(warehouse: Warehouse, c: Int, r: Int, str: String) -> Nil {
  case c >= size, r >= size {
    _, True -> {
      io.println(str)
    }
    True, False -> {
      print_grid(warehouse, 0, r + 1, str <> "\n")
    }
    False, False -> {
      let pos = Position(r:, c:)
      let assert Ok(tile) = dict.get(warehouse.map, pos)
      let char = case tile, warehouse.robot_position == pos {
        Empty, True -> "@"
        Empty, False -> "."
        Box, _ -> "O"
        Wall, _ -> "#"
        LeftBox, _ | RightBox, _ -> panic
      }
      print_grid(warehouse, c + 1, r, str <> char)
    }
  }
}

fn parse(input: String) -> Warehouse {
  let assert Ok(#(grid, moves)) = string.split_once(input, "\n\n")
  let #(map, robot_position) = parse_grid(grid)
  let moves = parse_moves(moves)
  Warehouse(moves:, map:, robot_position:)
}

fn parse_grid(input: String) -> #(dict.Dict(Position, Tile), Position) {
  use acc, line, r <- list.index_fold(string.split(input, "\n"), #(
    dict.new(),
    Position(0, 0),
  ))
  use #(grid, robot), char, c <- list.index_fold(string.to_graphemes(line), acc)
  let position = Position(r:, c:)
  case char {
    "#" -> #(dict.insert(grid, position, Wall), robot)
    "O" -> #(dict.insert(grid, position, Box), robot)
    "." -> #(dict.insert(grid, position, Empty), robot)
    "[" -> #(dict.insert(grid, position, LeftBox), robot)
    "]" -> #(dict.insert(grid, position, RightBox), robot)
    "@" -> #(dict.insert(grid, position, Empty), position)
    _ -> panic
  }
}

pub fn pt_2(input: String) -> Int {
  input
  |> widen
  |> parse
  |> iterate
  |> score
}

fn widen(input: String) -> String {
  input
  |> string.replace("#", "##")
  |> string.replace("O", "[]")
  |> string.replace(".", "..")
  |> string.replace("@", "@.")
}

fn do_move(move: Move, position: Position, tile: Tile, warehouse: Warehouse) -> Warehouse {
  let new_position = move_position(move, position)
  case dict.get(warehouse.map, position), move {
    Error(_), _ -> warehouse
    Ok(Wall), _ -> warehouse
    Ok(Empty), _ ->
      Warehouse(..warehouse, map: dict.insert(warehouse.map, position, tile))
    Ok(LeftBox), Up | Ok(LeftBox), Down -> {
      let moved = move_position(Right, position)
      case dict.get(warehouse.map, moved) {
        Ok(RightBox) -> {
          let warehouse =
            do_move(
              move,
              new_position,
              LeftBox,
              Warehouse(
                ..warehouse,
                map: dict.insert(warehouse.map, position, tile)
                  |> dict.insert(moved, Empty),
              ),
            )

          do_move(move, move_position(Right, new_position), RightBox, warehouse)
        }
        _ ->
          do_move(
            move,
            new_position,
            LeftBox,
            Warehouse(
              ..warehouse,
              map: dict.insert(warehouse.map, position, tile),
            ),
          )
      }
    }
    Ok(RightBox), Up | Ok(RightBox), Down -> {
      let moved = move_position(Left, position)
      case dict.get(warehouse.map, moved) {
        Ok(LeftBox) -> {
          let warehouse =
            do_move(
              move,
              new_position,
              RightBox,
              Warehouse(
                ..warehouse,
                map: dict.insert(warehouse.map, position, tile)
                  |> dict.insert(moved, Empty),
              ),
            )

          do_move(move, move_position(Left, new_position), LeftBox, warehouse)
        }
        _ ->
          do_move(
            move,
            new_position,
            LeftBox,
            Warehouse(
              ..warehouse,
              map: dict.insert(warehouse.map, position, tile),
            ),
          )
      }
    }
    Ok(new_tile), _ ->
      do_move(
        move,
        new_position,
        new_tile,
        Warehouse(..warehouse, map: dict.insert(warehouse.map, position, tile)),
      )
  }
}

fn can_move(move: Move, warehouse: Warehouse) -> Bool {
  let new_position = move_position(move, warehouse.robot_position)
  case dict.get(warehouse.map, new_position), move {
    Error(_), _ -> False
    Ok(Wall), _ -> False
    Ok(Empty), _ -> True
    Ok(LeftBox), Up | Ok(LeftBox), Down ->
      can_move(move, Warehouse(..warehouse, robot_position: new_position))
      && can_move(
        move,
        Warehouse(
          ..warehouse,
          robot_position: move_position(Right, new_position),
        ),
      )
    Ok(RightBox), Up | Ok(RightBox), Down ->
      can_move(move, Warehouse(..warehouse, robot_position: new_position))
      && can_move(
        move,
        Warehouse(
          ..warehouse,
          robot_position: move_position(Left, new_position),
        ),
      )
    Ok(LeftBox), _ | Ok(RightBox), _ | Ok(Box), _ ->
      can_move(move, Warehouse(..warehouse, robot_position: new_position))
  }
}

fn score(warehouse: Warehouse) -> Int {
  use sum, Position(r:, c:), tile <- dict.fold(warehouse.map, 0)
  case tile {
    LeftBox | Box -> sum + r * 100 + c
    _ -> sum
  }
}

fn print_grid2(warehouse: Warehouse, c: Int, r: Int, str: String) -> Nil {
  case c >= size * 2, r >= size {
    _, True -> {
      io.println(str)
    }
    True, False -> {
      print_grid2(warehouse, 0, r + 1, str <> "\n")
    }
    False, False -> {
      let pos = Position(r:, c:)
      let assert Ok(tile) = dict.get(warehouse.map, pos)
      let char = case tile, warehouse.robot_position == pos {
        Empty, True -> "@"
        Empty, False -> "."
        Wall, _ -> "#"
        LeftBox, _ -> "["
        RightBox, _ -> "]"
        Box, _ -> panic
      }
      print_grid2(warehouse, c + 1, r, str <> char)
    }
  }
}

fn parse_moves(input: String) -> List(Move) {
  use line <- list.flat_map(string.split(input, "\n"))
  use char <- list.map(string.to_graphemes(line))
  case char {
    "^" -> Up
    "v" -> Down
    "<" -> Left
    ">" -> Right
    _ -> panic
  }
}

type Tile {
  Box
  LeftBox
  RightBox
  Empty
  Wall
}

type Warehouse {
  Warehouse(
    moves: List(Move),
    map: dict.Dict(Position, Tile),
    robot_position: Position,
  )
}

type Position {
  Position(r: Int, c: Int)
}

type Move {
  Up
  Down
  Left
  Right
}
