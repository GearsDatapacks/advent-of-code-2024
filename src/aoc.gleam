import aoc/day3
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(inputs) = simplifile.read("inputs.txt")
  io.debug(day3.part1(inputs))
  io.debug(day3.part2(inputs))
}
