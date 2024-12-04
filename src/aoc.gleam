import day4
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(inputs) = simplifile.read("inputs.txt")
  io.debug(day4.part1(inputs))
  io.debug(day4.part2(inputs))
}
