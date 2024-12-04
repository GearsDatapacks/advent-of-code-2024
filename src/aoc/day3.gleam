import gleam/bool
import gleam/string

pub fn part1(inputs) {
  do_part1(inputs, 0)
}

fn do_part1(inputs, sum) {
  case inputs {
    "" -> sum
    "mul(" <> inputs -> {
      let #(inputs, num) = parse_mul(inputs)
      do_part1(inputs, num + sum)
    }
    _ -> {
      let assert Ok(#(_char, inputs)) = string.pop_grapheme(inputs)
      do_part1(inputs, sum)
    }
  }
}

fn parse_mul(inputs) {
  let #(inputs, num1) = parse_number(inputs, 0)
  use <- bool.guard(num1 == 0, #(inputs, 0))

  case inputs {
    "," <> inputs -> {
      let #(inputs, num2) = parse_number(inputs, 0)
      use <- bool.guard(num2 == 0, #(inputs, 0))

      case inputs {
        ")" <> inputs -> #(inputs, num1 * num2)
        _ -> #(inputs, 0)
      }
    }
    _ -> #(inputs, 0)
  }
}

fn parse_number(inputs, acc) {
  case inputs {
    "0" <> inputs -> parse_number(inputs, acc * 10 + 0)
    "1" <> inputs -> parse_number(inputs, acc * 10 + 1)
    "2" <> inputs -> parse_number(inputs, acc * 10 + 2)
    "3" <> inputs -> parse_number(inputs, acc * 10 + 3)
    "4" <> inputs -> parse_number(inputs, acc * 10 + 4)
    "5" <> inputs -> parse_number(inputs, acc * 10 + 5)
    "6" <> inputs -> parse_number(inputs, acc * 10 + 6)
    "7" <> inputs -> parse_number(inputs, acc * 10 + 7)
    "8" <> inputs -> parse_number(inputs, acc * 10 + 8)
    "9" <> inputs -> parse_number(inputs, acc * 10 + 9)
    _ -> #(inputs, acc)
  }
}

pub fn part2(inputs) {
  do_part2(inputs, 0, True)
}
fn do_part2(inputs, sum, enabled) {
  case inputs {
    "" -> sum
    "mul(" <> inputs if enabled -> {
      let #(inputs, num) = parse_mul(inputs)
      do_part2(inputs, num + sum, enabled)
    }
    "do()" <> inputs -> do_part2(inputs, sum, True)
    "don't()" <> inputs -> do_part2(inputs, sum, False)
    _ -> {
      let assert Ok(#(_char, inputs)) = string.pop_grapheme(inputs)
      do_part2(inputs, sum, enabled)
    }
  }
}