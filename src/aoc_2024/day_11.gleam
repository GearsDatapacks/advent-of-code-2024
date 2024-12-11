import aoc/utils
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import gleam_community/maths/elementary as maths

pub fn pt_1(input: String) {
  let stones = parse(input)
  iterate(stones, 25) |> list.length
}

fn iterate(stones: List(Int), count: Int) -> List(Int) {
  case count {
    0 -> stones
    _ -> {
      iterate(map_stones(stones, []), count - 1)
    }
  }
}

type Stones {
  One(Stone)
  Two(Stone, Stone)
}

type Stone =
  Int

fn map_stones(stones: List(Stone), acc: List(Stone)) -> List(Stone) {
  case stones {
    [] -> acc
    [stone, ..stones] ->
      case blink(stone) {
        One(stone) -> map_stones(stones, [stone, ..acc])
        Two(a, b) -> map_stones(stones, [a, b, ..acc])
      }
  }
}

fn blink(stone: Stone) -> Stones {
  case stone, digits(stone) {
    0, _ -> One(1)
    stone, length if length % 2 == 0 -> split(stone, length / 2)
    _, _ -> One(stone * 2024)
  }
}

fn digits(x: Stone) -> Int {
  case x {
    0 -> 1
    _ ->
      {
        x
        |> int.to_float
        |> maths.logarithm_10
        |> utils.unwrap
        |> float.truncate
      }
      + 1
  }
}

fn split(number: Int, index: Int) -> Stones {
  let splitter =
    int.power(10, int.to_float(index)) |> utils.unwrap |> float.truncate
  Two(number / splitter, number % splitter)
}

fn count_stone(
  stone: Stone,
  steps: Int,
  known: Dict(#(Stone, Int), Int),
) -> #(Int, Dict(#(Stone, Int), Int)) {
  case steps {
    0 -> #(1, known)
    _ ->
      case dict.get(known, #(stone, steps)) {
        Ok(count) -> #(count, known)
        Error(_) -> {
          let #(count, known) = case blink(stone) {
            One(stone) -> count_stone(stone, steps - 1, known)
            Two(a, b) -> {
              let #(count, known) = count_stone(a, steps - 1, known)
              let #(count2, known) = count_stone(b, steps - 1, known)
              #(count + count2, known)
            }
          }
          #(count, dict.insert(known, #(stone, steps), count))
        }
      }
  }
}

pub fn pt_2(input: String) {
  let stones = parse(input)
  list.fold(stones, #(0, dict.new()), fn(acc, stone) {
    let #(count, known) = count_stone(stone, 75, acc.1)
    #(count + acc.0, known)
  }).0
}

fn parse(input: String) {
  string.split(input, " ") |> list.filter_map(int.parse)
}
