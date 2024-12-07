import aoc/utils
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import gleam_community/maths/elementary as maths

pub fn pt_1(input: String) -> Int {
  let equations = parse(input)
  equations
  |> list.filter_map(fn(equation) {
    case could_be_true(equation.0, equation.1, Part1) {
      True -> Ok(equation.0)
      False -> Error(Nil)
    }
  })
  |> int.sum
}

fn could_be_true(test_value: Int, operands: List(Int), part: Part) -> Bool {
  let assert [first, ..operands] = operands
  check(first, test_value, operands, part)
}

fn check(acc: Int, target: Int, operands: List(Int), part: Part) -> Bool {
  case operands {
    [] -> acc == target
    _ if acc > target -> False
    [x, ..operands] -> {
      case check(acc + x, target, operands, part) {
        True -> True
        False ->
          case check(acc * x, target, operands, part), part {
            True, _ -> True
            False, Part1 -> False
            False, Part2 -> check(concat(acc, x), target, operands, part)
          }
      }
    }
  }
}

fn concat(a: Int, b: Int) -> Int {
  let len =
    b
    |> int.to_float
    |> maths.logarithm_10
    |> utils.unwrap
    |> float.floor
  let shift = float.truncate(utils.unwrap(int.power(10, len +. 1.0)))
  a * shift + b
}

type Part {
  Part1
  Part2
}

pub fn pt_2(input: String) -> Int {
  let equations = parse(input)
  equations
  |> list.filter_map(fn(equation) {
    case could_be_true(equation.0, equation.1, Part2) {
      True -> Ok(equation.0)
      False -> Error(Nil)
    }
  })
  |> int.sum
}

fn parse(input: String) -> List(#(Int, List(Int))) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(#(test_value, operands)) = string.split_once(line, ": ")
  let assert Ok(test_value) = int.parse(test_value)
  let operands = operands |> string.split(" ") |> list.filter_map(int.parse)
  #(test_value, operands)
}
