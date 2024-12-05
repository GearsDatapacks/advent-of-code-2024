import aoc/utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

type Rule {
  Rule(before: Int, after: Int)
}

type Update =
  List(Int)

type Relationships {
  Relationships(before: List(Int), after: List(Int))
}

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
  let mapped_rules =
    list.fold(rules, dict.new(), fn(rules, rule) {
      rules
      |> dict.upsert(rule.before, fn(relationships) {
        case relationships {
          None -> Relationships(before: [], after: [rule.after])
          Some(relationships) ->
            Relationships(
              ..relationships,
              after: [rule.after, ..relationships.after],
            )
        }
      })
      |> dict.upsert(rule.after, fn(relationships) {
        case relationships {
          None -> Relationships(before: [rule.before], after: [])
          Some(relationships) ->
            Relationships(
              ..relationships,
              before: [rule.before, ..relationships.before],
            )
        }
      })
    })

  updates
  |> list.filter(utils.not(is_correct(_, rules)))
  |> list.map(fn(update) { update |> reorder(mapped_rules) |> middle })
  |> int.sum
}

fn reorder(update: Update, rules: Dict(Int, Relationships)) -> Update {
  case update {
    [] -> []
    [first] -> [first]
    [first, ..] -> {
      let assert Ok(Relationships(before:, after:)) = dict.get(rules, first)

      let before =
        list.filter(before, fn(number) { list.contains(update, number) })
      let after =
        list.filter(after, fn(number) { list.contains(update, number) })

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
