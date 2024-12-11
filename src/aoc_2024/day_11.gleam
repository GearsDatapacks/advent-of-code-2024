import aoc/utils
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam_community/maths/elementary as maths
import rememo/memo

pub fn pt_1(input: String) -> Stone {
  input |> parse |> count_stones(25)
}

type Stone =
  Int

fn digits(x: Stone) -> Int {
  {
    x
    |> int.to_float
    |> maths.logarithm_10
    |> result.unwrap(0.0)
    |> float.truncate
  }
  + 1
}

fn split(stone: Stone, index: Int) -> #(Stone, Stone) {
  let splitter =
    int.power(10, int.to_float(index)) |> utils.unwrap |> float.truncate
  #(stone / splitter, stone % splitter)
}

fn count_stone(stone: Stone, steps: Int, cache) -> Int {
  use <- memo.memoize(cache, #(stone, steps))
  case steps {
    0 -> 1
    _ ->
      case stone, digits(stone) {
        0, _ -> count_stone(1, steps - 1, cache)
        stone, length if length % 2 == 0 -> {
          let #(upper, lower) = split(stone, length / 2)
          count_stone(upper, steps - 1, cache)
          + count_stone(lower, steps - 1, cache)
        }
        _, _ -> count_stone(stone * 2024, steps - 1, cache)
      }
  }
}

fn count_stones(stones: List(Stone), steps: Int) -> Int {
  use cache <- memo.create
  list.fold(stones, 0, fn(acc, stone) { acc + count_stone(stone, steps, cache) })
}

pub fn pt_2(input: String) -> Stone {
  input |> parse |> count_stones(75)
}

fn parse(input: String) -> List(Stone) {
  string.split(input, " ") |> list.filter_map(int.parse)
}
