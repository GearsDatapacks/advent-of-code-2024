import aoc/utils
import gleam/int
import gleam/list
import gleam/string

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
  use operators <- list.any(operator_combinations(list.length(operands), [[]], part))
  let result = operands |> list.zip(operators) |> evaluate(first, _)
  result == test_value
}

fn evaluate(initial: Int, operation: List(#(Int, Operator))) -> Int {
  use acc, #(x, op) <- list.fold(operation, initial)
  case op {
    Plus -> acc + x
    Times -> acc * x
    Concatenate ->
      int.parse(int.to_string(acc) <> int.to_string(x)) |> utils.unwrap
  }
}

type Operator {
  Plus
  Times
  Concatenate
}

type Part {
  Part1
  Part2
}

fn operator_combinations(length: Int, acc: List(List(Operator)), part: Part) -> List(List(Operator)) {
  case length {
    0 -> acc
    _ -> {
      let plus = acc |> list.map(fn(operators) { [Plus, ..operators] })
      let times = acc |> list.map(fn(operators) { [Times, ..operators] })
      let concat = case part {
        Part1 -> []
        Part2 -> acc |> list.map(fn(operators) { [Concatenate, ..operators] })
      }
      operator_combinations(
        length - 1,
        list.flatten([plus, times, concat]),
        part,
      )
    }
  }
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
