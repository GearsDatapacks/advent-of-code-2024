import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn part1(inputs) {
  let #(list1, list2) = parse(inputs)
  let list1 = list.sort(list1, int.compare)
  let list2 = list.sort(list2, int.compare)
  use count, #(a, b) <- list.fold(list.zip(list1, list2), 0)
  count + int.absolute_value(a - b)
}

fn parse(inputs) {
  inputs
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [first, last] = string.split(line, "   ")
    let assert Ok(first) = int.parse(first)
    let assert Ok(last) = int.parse(last)
    #(first, last)
  })
  |> list.unzip
}

pub fn part2(inputs) {
  let #(list1, list2) = parse(inputs)
  let counts =
    list.fold(list2, dict.new(), fn(counts, next) {
      dict.upsert(counts, next, fn(count) { option.unwrap(count, 0) + 1 })
    })

  use sum, value <- list.fold(list1, 0)
  let count_in_second = dict.get(counts, value) |> result.unwrap(0)
  sum + value * count_in_second
}
