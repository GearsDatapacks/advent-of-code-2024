import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub fn pt_1(inputs) {
  parse(inputs)
  |> list.count(is_safe)
}

type Order {
  Increasing
  Decreasing
}

fn is_safe(report) {
  let assert [first, second, ..] = report
  let order = case second > first {
    False -> Decreasing
    True -> Increasing
  }
  use #(a, b) <- list.all(list.window_by_2(report))
  case int.compare(b, a), order {
    order.Gt, Increasing -> b - a <= 3
    order.Lt, Decreasing -> a - b <= 3
    _, _ -> False
  }
}

fn parse(inputs) {
  inputs
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(" ") |> list.filter_map(int.parse)
  })
}

pub fn pt_2(inputs) {
  parse(inputs)
  |> list.count(is_safe_with_dampening)
}

fn is_safe_with_dampening(report) {
  case is_safe(report) {
    True -> True
    False ->
      report
      |> list.combinations(list.length(report) - 1)
      |> list.any(is_safe)
  }
}
