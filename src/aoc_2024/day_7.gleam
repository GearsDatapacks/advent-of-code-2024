import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let equations = parse(input)
  equations
  |> list.filter_map(fn(equation) {
    case could_be_true(equation.0, equation.1) {
      True -> Ok(equation.0)
      False -> Error(Nil)
    }
  })
  |> int.sum
}

fn could_be_true(test_value: Int, operands: List(Int)) {
  let assert [first, ..operands] = operands
  use operators <- list.any(operator_combinations(list.length(operands), [[]]))
  let result = operands |> list.zip(operators) |> evaluate(first, _)
  result == test_value
}

fn evaluate(initial, operation: List(#(Int, Operator))) {
  use acc, #(x, op) <- list.fold(operation, initial)
  case op {
    Plus -> acc + x
    Times -> acc * x
  }
}

type Operator {
  Plus
  Times
}

fn operator_combinations(length: Int, acc: List(List(Operator))) {
  case length {
    0 -> acc
    _ ->
      acc
      |> list.map(fn(operators) { [Plus, ..operators] })
      |> list.append(acc |> list.map(fn(operators) { [Times, ..operators] }))
      |> operator_combinations(length - 1, _)
  }
}

pub fn pt_2(input: String) {
  let equations = parse(input)
  equations
  |> list.filter_map(fn(equation) {
    case could_be_true2(equation.0, equation.1) {
      True -> Ok(equation.0)
      False -> Error(Nil)
    }
  })
  |> int.sum
}

fn could_be_true2(test_value: Int, operands: List(Int)) {
  let assert [first, ..operands] = operands
  use operators <- list.any(operator_combinations2(list.length(operands), [[]]))
  let result = operands |> list.zip(operators) |> evaluate2(first, _)
  result == test_value
}

fn evaluate2(initial, operation: List(#(Int, Operator2))) {
  use acc, #(x, op) <- list.fold(operation, initial)
  case op {
    Concat -> {
      let x_len = x |> int.to_string |> string.length
      let assert Ok(pow) = int.power(10, int.to_float(x_len))
      acc * float.truncate(pow) + x
    }
    Plus2 -> acc + x
    Times2 -> acc * x
  }
}

type Operator2 {
  Plus2
  Times2
  Concat
}

fn operator_combinations2(length: Int, acc: List(List(Operator2))) {
  case length {
    0 -> acc
    _ ->
      acc
      |> list.map(fn(operators) { [Plus2, ..operators] })
      |> list.append(acc |> list.map(fn(operators) { [Times2, ..operators] }))
      |> list.append(acc |> list.map(fn(operators) { [Concat, ..operators] }))
      |> operator_combinations2(length - 1, _)
  }
}

fn parse(input: String) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(#(test_value, operands)) = string.split_once(line, ": ")
  let assert Ok(test_value) = int.parse(test_value)
  let operands = operands |> string.split(" ") |> list.filter_map(int.parse)
  #(test_value, operands)
}
