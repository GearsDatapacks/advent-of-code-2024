import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import rememo/memo

pub fn pt_1(input: String) {
  let #(available, desired) = parse(input)
  list.count(desired, possible(_, available))
}

fn possible(pattern, available) {
  use <- bool.guard(pattern == "", True)
  use towel <- list.any(available)
  case strip_prefix(pattern, towel) {
    Ok(rest) -> possible(rest, available)
    Error(_) -> False
  }
}

fn strip_prefix(string, prefix) {
  case string.starts_with(string, prefix) {
    False -> Error(Nil)
    True -> Ok(string.drop_start(string, string.length(prefix)))
  }
}

pub fn pt_2(input: String) {
  let #(available, desired) = parse(input)
  use cache <- memo.create
  list.map(desired, possible2(_, available, cache)) |> int.sum
}

fn possible2(pattern, available, cache) {
  use <- bool.guard(pattern == "", 1)
  use <- memo.memoize(cache, pattern)
  available
  |> list.map(fn(towel) {
    case strip_prefix(pattern, towel) {
      Ok(rest) -> possible2(rest, available, cache)
      Error(_) -> 0
    }
  })
  |> int.sum
}

fn parse(input) {
  let assert Ok(#(available, desired)) = string.split_once(input, "\n\n")
  let available = string.split(available, ", ")
  let desired = string.split(desired, "\n")
  #(available, desired)
}
