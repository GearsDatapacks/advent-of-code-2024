import gleam/io
import simplifile

pub fn main() {
  let assert Ok(inputs) = simplifile.read("inputs.txt")
  io.debug(inputs)
}
