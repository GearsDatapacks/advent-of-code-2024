import aoc/day2
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(inputs) = simplifile.read("inputs.txt")
  io.debug(day2.part1(inputs))
  io.debug(day2.part2(inputs))
}
