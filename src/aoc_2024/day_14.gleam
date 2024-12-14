import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set.{type Set}
import gleam/string

const width = 101

const height = 103

pub fn pt_1(input: String) -> Int {
  let quadrants =
    input
    |> parse
    |> list.map(update_robot(_, 100))
    |> file_quadrants

  quadrants.top_left
  * quadrants.top_right
  * quadrants.bottom_left
  * quadrants.bottom_right
}

type Quadrants {
  Quadrants(top_left: Int, top_right: Int, bottom_left: Int, bottom_right: Int)
}

fn update_robot(robot: Robot, count: Int) -> Robot {
  let position = add(robot.position, mul(robot.velocity, count))
  let assert Ok(x) = int.modulo(position.x, width)
  let assert Ok(y) = int.modulo(position.y, height)
  Robot(..robot, position: Vector(x:, y:))
}

fn file_quadrants(robots: List(Robot)) -> Quadrants {
  use quadrants, robot <- list.fold(robots, Quadrants(0, 0, 0, 0))
  case
    int.compare(robot.position.x, width / 2),
    int.compare(robot.position.y, height / 2)
  {
    order.Eq, _ | _, order.Eq -> quadrants
    order.Lt, order.Lt ->
      Quadrants(..quadrants, top_left: quadrants.top_left + 1)
    order.Gt, order.Lt ->
      Quadrants(..quadrants, top_right: quadrants.top_right + 1)
    order.Lt, order.Gt ->
      Quadrants(..quadrants, bottom_left: quadrants.bottom_left + 1)
    order.Gt, order.Gt ->
      Quadrants(..quadrants, bottom_right: quadrants.bottom_right + 1)
  }
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse
  |> loop(0)
}

fn loop(robots: List(Robot), count: Int) -> Int {
  case count {
    10_000 -> panic as "Tree not found in 10k iterations"
    _ -> {
      let text =
        print_robots(
          set.from_list(list.map(robots, fn(robot) { robot.position })),
          0,
          0,
          "",
        )
      // You're pretty unlucky if the robots line up like this before the actual tree
      case string.contains(text, "###############################") {
        True -> {
          io.println(text)
          count
        }
        False -> loop(list.map(robots, update_robot(_, 1)), count + 1)
      }
    }
  }
}

fn print_robots(robots: Set(Vector), x: Int, y: Int, str: String) -> String {
  case x >= width, y >= height {
    _, True -> str
    True, False -> {
      print_robots(robots, 0, y + 1, str <> "\n")
    }
    False, False -> {
      let robot = set.contains(robots, Vector(x:, y:))
      let print = case robot {
        False -> "."
        True -> "#"
      }
      print_robots(robots, x + 1, y, str <> print)
    }
  }
}

fn parse(input: String) -> List(Robot) {
  use line <- list.map(string.split(input, "\n"))
  let assert "p=" <> line = line
  let assert Ok(#(position, velocity)) = string.split_once(line, " v=")
  let position = parse_vector(position)
  let velocity = parse_vector(velocity)
  Robot(position:, velocity:)
}

fn parse_vector(input: String) -> Vector {
  let assert Ok(#(x, y)) = string.split_once(input, ",")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x:, y:)
}

type Robot {
  Robot(position: Vector, velocity: Vector)
}

type Vector {
  Vector(x: Int, y: Int)
}

fn add(a: Vector, b: Vector) -> Vector {
  Vector(x: a.x + b.x, y: a.y + b.y)
}

fn mul(v: Vector, n: Int) -> Vector {
  Vector(x: v.x * n, y: v.y * n)
}
