import gleam/set.{type Set}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string

const width = 101

const height = 103

pub fn pt_1(input: String) {
  let robots = parse(input)
  let robots = update_robots(robots, 100)
  let quadrants = file_quadrants(robots)
  quadrants.top_left
  * quadrants.top_right
  * quadrants.bottom_left
  * quadrants.bottom_right
}

type Quadrants {
  Quadrants(top_left: Int, top_right: Int, bottom_left: Int, bottom_right: Int)
}

fn update_robots(robots: List(Robot), count) {
  case count {
    0 -> robots
    _ -> update_robots(list.map(robots, update_robot), count - 1)
  }
}

fn update_robot(robot: Robot) {
  let position = add(robot.position, robot.velocity)
  let position = Vector(x: wrap(position.x, width), y: wrap(position.y, height))
  Robot(..robot, position:)
}

fn wrap(value, by) {
  let value = value % by
  case value < 0 {
    False -> value
    True -> wrap(value + by, by)
  }
}

fn file_quadrants(robots: List(Robot)) {
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

pub fn pt_2(input: String) {
  let robots = parse(input)
  loop(robots, 0)
  panic
}

fn loop(robots: List(Robot), count) {
  case count {
    10000 -> Nil
    _ -> {
      io.println_error(int.to_string(count))
      print_robots(set.from_list(list.map(robots, fn(robot) {robot.position})), 0, 0, "")
      loop(list.map(robots, update_robot), count + 1)
    }
  }
}

fn print_robots(robots: Set(Vector), x, y, str) {
  case x >= width, y >= height {
    _, True -> io.println_error(str <> "\n")
    True, False -> {
      print_robots(robots, 0, y + 1, str <> "\n")
    }
    False, False -> {
      let robot =
        set.contains(robots, Vector(x:, y:))
      let print = case robot {
        False -> "."
        True -> "#"
      }
      print_robots(robots, x + 1, y, str <> print)
    }
  }
}

fn parse(input) {
  use line <- list.map(string.split(input, "\n"))
  let assert "p=" <> line = line
  let assert Ok(#(position, velocity)) = string.split_once(line, " v=")
  let position = parse_vector(position)
  let velocity = parse_vector(velocity)
  Robot(position:, velocity:)
}

fn parse_vector(input) {
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

fn add(a: Vector, b: Vector) {
  Vector(x: a.x + b.x, y: a.y + b.y)
}
