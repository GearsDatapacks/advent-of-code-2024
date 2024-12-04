import aoc/day1
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(inputs) = simplifile.read("inputs.txt")
  io.debug(day1.part1(inputs))
  io.debug(day1.part2(inputs))
}
