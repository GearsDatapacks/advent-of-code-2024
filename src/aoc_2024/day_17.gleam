import gleam/io
import aoc/utils
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let #(computer, _) = parse(input)
  run(computer, [])
  |> list.reverse
  |> list.map(int.to_string)
  |> string.join(",")
}

fn run(computer: Computer, out) {
  case
    dict.get(computer.instructions, computer.ip),
    dict.get(computer.instructions, computer.ip + 1)
  {
    Ok(opcode), Ok(operand) -> {
      let ip = computer.ip + 2
      case opcode {
        0 -> {
          let operand = combo(computer, operand)
          let value =
            computer.a
            / float.truncate(utils.unwrap(int.power(2, int.to_float(operand))))
          let computer = Computer(..computer, ip:, a: value)
          run(computer, out)
        }
        1 -> {
          let value = int.bitwise_exclusive_or(computer.b, operand)
          let computer = Computer(..computer, ip:, b: value)
          run(computer, out)
        }
        2 -> {
          let operand = combo(computer, operand)
          let value = operand % 8
          let computer = Computer(..computer, ip:, b: value)
          run(computer, out)
        }
        3 -> {
          let ip = case computer.a == 0 {
            True -> ip
            False -> operand
          }
          let computer = Computer(..computer, ip:)
          run(computer, out)
        }
        4 -> {
          let value = int.bitwise_exclusive_or(computer.b, computer.c)
          let computer = Computer(..computer, ip:, b: value)
          run(computer, out)
        }
        5 -> {
          let operand = combo(computer, operand)
          let value = operand % 8
          let computer = Computer(..computer, ip:)
          run(computer, [value, ..out])
        }
        6 -> {
          let operand = combo(computer, operand)
          let value =
            computer.a
            / float.truncate(utils.unwrap(int.power(2, int.to_float(operand))))
          let computer = Computer(..computer, ip:, b: value)
          run(computer, out)
        }
        7 -> {
          let operand = combo(computer, operand)
          let value =
            computer.a
            / float.truncate(utils.unwrap(int.power(2, int.to_float(operand))))
          let computer = Computer(..computer, ip:, c: value)
          run(computer, out)
        }
        _ -> panic
      }
    }
    _, _ -> out
  }
}

fn combo(computer: Computer, operand) {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> computer.a
    5 -> computer.b
    6 -> computer.c
    _ -> panic
  }
}

pub fn pt_2(input: String) {
  let #(computer, program) = parse(input)
  let start = int.bitwise_shift_left(1, dict.size(computer.instructions) * 3)
  io.debug(start)
  find(computer, program, start)
}

fn find(computer, program, value) {
  let computer = Computer(..computer, a: value)
  let out =
    run(computer, [])
    |> list.reverse
    |> list.map(int.to_string)
    |> string.join(",")
  case out == program {
    True -> value
    False -> find(computer, program, value + 1)
  }
}

fn parse(input) {
  let assert [a, b, c, _blank, program] = string.split(input, "\n")
  let assert "Register A: " <> a = a
  let assert Ok(a) = int.parse(a)
  let assert "Register B: " <> b = b
  let assert Ok(b) = int.parse(b)
  let assert "Register C: " <> c = c
  let assert Ok(c) = int.parse(c)
  let assert "Program: " <> program = program
  let instructions =
    program
    |> string.split(",")
    |> list.filter_map(int.parse)
    |> list.index_fold(dict.new(), fn(d, n, i) { dict.insert(d, i, n) })

  #(Computer(instructions:, a:, b:, c:, ip: 0), program)
}

type Computer {
  Computer(instructions: Dict(Int, Int), a: Int, b: Int, c: Int, ip: Int)
}
