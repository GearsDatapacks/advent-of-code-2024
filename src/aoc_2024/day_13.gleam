import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) -> Int {
  input
  |> parse(Part1)
  |> list.fold(0, fn(sum, machine) { tokens_for_machine(machine) + sum })
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse(Part2)
  |> list.fold(0, fn(sum, machine) { tokens_for_machine(machine) + sum })
}

fn tokens_for_machine(machine: Machine) -> Int {
  let a =
    Equation(
      a: int.to_float(machine.a.x),
      b: int.to_float(machine.b.x),
      p: int.to_float(machine.prize.x),
    )
  let b =
    Equation(
      a: int.to_float(machine.a.y),
      b: int.to_float(machine.b.y),
      p: int.to_float(machine.prize.y),
    )

  let #(x, y) = solve(a, b)

  case
    float.loosely_equals(x, int.to_float(float.round(x)), 0.01)
    && float.loosely_equals(y, int.to_float(float.round(y)), 0.01)
  {
    False -> 0
    True -> float.round(x) * 3 + float.round(y)
  }
}

/// ax + bx = p
type Equation {
  Equation(a: Float, b: Float, p: Float)
}

/// ax/b = p/b - y
type Rearranged {
  Rearranged(l: Float, r: Float)
}

fn rearrange(equation: Equation) -> Rearranged {
  Rearranged(l: equation.a /. equation.b, r: equation.p /. equation.b)
}

fn solve(a: Equation, b: Equation) -> #(Float, Float) {
  let ra = rearrange(a)
  let rb = rearrange(b)
  let diff = ra.r -. rb.r
  let x = diff /. { ra.l -. rb.l }
  let y = { a.p -. x *. a.a } /. a.b
  #(x, y)
}

fn parse(input: String, part: Part) -> List(Machine) {
  use machine <- list.map(string.split(input, "\n\n"))
  let assert [a, b, prize] = string.split(machine, "\n")
  let a = parse_a(a)
  let b = parse_b(b)
  let prize = parse_prize(prize, part)

  Machine(a:, b:, prize:)
}

fn parse_a(a: String) -> Vector {
  let assert "Button A: X+" <> a = a
  let assert Ok(#(x, y)) = string.split_once(a, ", Y+")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x:, y:)
}

fn parse_b(b: String) -> Vector {
  let assert "Button B: X+" <> b = b
  let assert Ok(#(x, y)) = string.split_once(b, ", Y+")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x:, y:)
}

fn parse_prize(prize: String, part: Part) -> Vector {
  let assert "Prize: X=" <> prize = prize
  let assert Ok(#(x, y)) = string.split_once(prize, ", Y=")
  let add = case part {
    Part1 -> 0
    Part2 -> 10_000_000_000_000
  }
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x: x + add, y: y + add)
}

type Vector {
  Vector(x: Int, y: Int)
}

type Machine {
  Machine(a: Vector, b: Vector, prize: Vector)
}

type Part {
  Part1
  Part2
}
