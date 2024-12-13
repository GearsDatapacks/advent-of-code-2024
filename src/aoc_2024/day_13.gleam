import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam_community/maths/combinatorics

pub fn pt_1(input: String) {
  let machines = parse(input)
  use sum, machine <- list.fold(machines, 0)
  let tokens =
    list.filter_map(
      combinatorics.cartesian_product(list.range(0, 100), list.range(0, 100)),
      fn(pair) {
        let #(a, b) = pair
        case add(mul(machine.a, a), mul(machine.b, b)) == machine.prize {
          True -> {
            Ok(a * 3 + b * 1)
          }
          False -> Error(Nil)
        }
      },
    )
    |> list.reduce(int.min)
    |> result.unwrap(0)

  tokens + sum
}

pub fn pt_2(input: String) {
  let machines = parse2(input)
  use sum, machine <- list.fold(machines, 0)
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

  let tokens = case
    float.loosely_equals(x, int.to_float(float.round(x)), 0.01)
    && float.loosely_equals(y, int.to_float(float.round(y)), 0.01)
  {
    False -> 0
    True -> float.round(x) * 3 + float.round(y)
  }

  tokens + sum
}

type Equation {
  Equation(a: Float, b: Float, p: Float)
}

type Rearranged {
  Rearranged(l: Float, r: Float)
}

fn rearrange(equation: Equation) {
  Rearranged(l: equation.a /. equation.b, r: equation.p /. equation.b)
}

fn solve(a: Equation, b: Equation) {
  let ra = rearrange(a)
  let rb = rearrange(b)
  let diff = ra.r -. rb.r
  let x = diff /. { ra.l -. rb.l }
  let y = { a.p -. x *. a.a } /. a.b
  #(x, y)
}

fn parse(input: String) {
  use machine <- list.map(string.split(input, "\n\n"))
  let assert [a, b, prize] = string.split(machine, "\n")
  let a = parse_a(a)
  let b = parse_b(b)
  let prize = parse_prize(prize)

  Machine(a:, b:, prize:)
}

fn parse2(input: String) {
  use machine <- list.map(string.split(input, "\n\n"))
  let assert [a, b, prize] = string.split(machine, "\n")
  let a = parse_a(a)
  let b = parse_b(b)
  let prize = parse_prize2(prize)

  Machine(a:, b:, prize:)
}

fn parse_a(a) {
  let assert "Button A: X+" <> a = a
  let assert Ok(#(x, y)) = string.split_once(a, ", Y+")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x:, y:)
}

fn parse_b(b) {
  let assert "Button B: X+" <> b = b
  let assert Ok(#(x, y)) = string.split_once(b, ", Y+")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x:, y:)
}

fn parse_prize(prize) {
  let assert "Prize: X=" <> prize = prize
  let assert Ok(#(x, y)) = string.split_once(prize, ", Y=")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x:, y:)
}

fn parse_prize2(prize) {
  let assert "Prize: X=" <> prize = prize
  let assert Ok(#(x, y)) = string.split_once(prize, ", Y=")
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  Vector(x + 10_000_000_000_000, y + 10_000_000_000_000)
}

type Vector {
  Vector(x: Int, y: Int)
}

fn mul(v: Vector, n) {
  Vector(x: v.x * n, y: v.y * n)
}

fn add(a: Vector, b: Vector) {
  Vector(x: a.x + b.x, y: a.y + b.y)
}

fn sub(a: Vector, b: Vector) {
  Vector(x: a.x - b.x, y: a.y - b.y)
}

type Machine {
  Machine(a: Vector, b: Vector, prize: Vector)
}
