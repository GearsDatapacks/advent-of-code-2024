import aoc_2024/day_6
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn day6_test() {
  day_6.move(day_6.Position(0, 0), day_6.Right) |> should.equal(day_6.Position(x: 1, y: 0))
}
