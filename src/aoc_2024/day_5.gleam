import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import aoc/utils

pub fn pt_1(input: String) {
  let #(rules, updates) = parse(input)
  updates
  |> list.filter(is_correct(_, rules))
  |> list.map(middle)
  |> int.sum
}

fn is_correct(order: List(Int), rules: List(#(Int, Int))) -> Bool {
  rules
  |> list.all(fn(rule) {
    case utils.index_of(order, rule.0), utils.index_of(order, rule.1) {
      Ok(first), Ok(second) -> first < second
      _, _ -> True
    }
  })
}

fn middle(list: List(Int)) -> Int {
  let length = list.length(list)
  let middle_index = length / 2
  let assert Ok(middle) =
    list
    |> utils.at(middle_index)
  middle
}

pub fn pt_2(input: String) {
  let #(rules, updates) = parse(input)
  updates
  |> list.filter(utils.not(is_correct(_, rules)))
  |> list.map(reorder(_, rules))
  |> list.map(middle) |> int.sum
}

fn reorder(list, rules: List(#(Int, Int))) {
  case list {
    [] -> []
    [first] -> [first]
    [first, ..] -> {
      let #(before, after) =
        rules
        |> list.filter(fn(rule) { list.contains(list, rule.0) && list.contains(list, rule.1) })
        |> list.filter(fn(rule) { rule.0 == first || rule.1 == first })
        |> list.partition(fn(rule) { first == rule.1 })

      let before = list.map(before, pair.first)
      let after = list.map(after, pair.second)

      list.flatten([reorder(before, rules), [first], reorder(after, rules)])
    }
  }
}

fn parse(input: String) -> #(List(#(Int, Int)), List(List(Int))) {
  let assert Ok(#(part1, part2)) = string.split_once(input, "\n\n")
  let rules =
    part1
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [a, b] =
        line |> string.split("|") |> list.filter_map(int.parse)
      #(a, b)
    })
  let updates =
    part2
    |> string.split("\n")
    |> list.map(fn(line) {
      line |> string.split(",") |> list.filter_map(int.parse)
    })

  #(rules, updates)
}
