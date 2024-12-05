import aoc/utils
import gleam/int
import gleam/list
import gleam/string

type Rule {
  Rule(before: Int, after: Int)
}

type Update =
  List(Int)

pub fn pt_1(input: String) -> Int {
  let #(rules, updates) = parse(input)
  updates
  |> list.filter(is_correct(_, rules))
  |> list.map(middle)
  |> int.sum
}

fn is_correct(update: Update, rules: List(Rule)) -> Bool {
  rules
  |> list.all(fn(rule) {
    case
      utils.index_of(update, rule.before),
      utils.index_of(update, rule.after)
    {
      Ok(before_index), Ok(after_index) -> before_index < after_index
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

pub fn pt_2(input: String) -> Int {
  let #(rules, updates) = parse(input)
  updates
  |> list.filter(utils.not(is_correct(_, rules)))
  |> list.map(reorder(_, rules))
  |> list.map(middle)
  |> int.sum
}

fn reorder(update: Update, rules: List(Rule)) -> Update {
  case update {
    [] -> []
    [first] -> [first]
    [first, ..] -> {
      let #(before, after) =
        rules
        |> list.filter(fn(rule) {
          { rule.before == first && list.contains(update, rule.after) }
          || { rule.after == first && list.contains(update, rule.before) }
        })
        |> list.partition(fn(rule) { first == rule.after })

      let before = list.map(before, fn(rule) { rule.before })
      let after = list.map(after, fn(rule) { rule.after })

      list.flatten([reorder(before, rules), [first], reorder(after, rules)])
    }
  }
}

fn parse(input: String) -> #(List(Rule), List(Update)) {
  let assert Ok(#(part1, part2)) = string.split_once(input, "\n\n")
  let rules =
    part1
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [before, after] =
        line |> string.split("|") |> list.filter_map(int.parse)
      Rule(before:, after:)
    })

  let updates =
    part2
    |> string.split("\n")
    |> list.map(fn(line) {
      line |> string.split(",") |> list.filter_map(int.parse)
    })

  #(rules, updates)
}
