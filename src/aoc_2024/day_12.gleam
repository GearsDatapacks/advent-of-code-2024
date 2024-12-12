import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn pt_1(input: String) -> Int {
  let map = parse(input)
  calculate_fences(map, dict.keys(map), 0, Part1)
}

const directions = [
  Vector(x: 1, y: 0),
  Vector(x: -1, y: 0),
  Vector(x: 0, y: 1),
  Vector(x: 0, y: -1),
]

pub fn pt_2(input: String) -> Int {
  let map = parse(input)
  calculate_fences(map, dict.keys(map), 0, Part2)
}

fn calculate_fences(
  map: Dict(Vector, Plot),
  positions: List(Vector),
  sum: Int,
  part: Part,
) -> Int {
  case positions {
    [] -> sum
    [position, ..positions] ->
      case dict.get(map, position) {
        Ok(plot) -> {
          let #(map, cost) = calculate_cost(map, position, plot, part)
          calculate_fences(map, positions, sum + cost, part)
        }
        Error(_) -> calculate_fences(map, positions, sum, part)
      }
  }
}

fn calculate_cost(
  map: Dict(Vector, Plot),
  position: Vector,
  plot: Plot,
  part: Part,
) -> #(Dict(Vector, Plot), Int) {
  let #(region, edges) = find_region(map, position, plot, set.new(), set.new())
  let area = set.size(region)
  let map =
    set.fold(region, map, fn(map, position) { dict.delete(map, position) })
  let perimeter = case part {
    Part1 -> set.size(edges)
    Part2 -> count_edges(edges, 0)
  }
  #(map, area * perimeter)
}

fn find_region(
  map: Dict(Vector, Plot),
  position: Vector,
  plot: Plot,
  region: Set(Vector),
  edges: Set(Edge),
) -> #(Set(Vector), Set(Edge)) {
  use <- bool.guard(set.contains(region, position), #(region, edges))
  let region = set.insert(region, position)

  let #(region, edges) =
    list.fold(directions, #(region, edges), fn(acc, direction) {
      let #(region, edges) = acc
      let new_position = add(position, direction)

      case dict.get(map, new_position) {
        Ok(p) if p == plot -> {
          let #(region, edges) =
            find_region(map, new_position, plot, region, edges)
          #(region, edges)
        }
        _ -> #(region, set.insert(edges, Edge(position, new_position)))
      }
    })

  #(set.insert(region, position), edges)
}

fn count_edges(edges: Set(Edge), count: Int) -> Int {
  case set.to_list(edges) {
    [] -> count
    [edge, ..] -> {
      let direction = sub(edge.edge_position, edge.empty_position)
      let #(left, right) = perpendicular(direction)
      let edges = edges |> trace_edge(edge, left) |> trace_edge(edge, right)
      count_edges(edges, count + 1)
    }
  }
}

fn trace_edge(edges: Set(Edge), edge: Edge, direction: Vector) -> Set(Edge) {
  let edges = set.delete(edges, edge)
  let new_edge =
    Edge(
      edge_position: add(edge.edge_position, direction),
      empty_position: add(edge.empty_position, direction),
    )
  case set.contains(edges, new_edge) {
    True -> trace_edge(edges, new_edge, direction)
    False -> edges
  }
}

type Vector {
  Vector(x: Int, y: Int)
}

fn add(a: Vector, b: Vector) {
  Vector(x: a.x + b.x, y: a.y + b.y)
}

fn sub(a: Vector, b: Vector) {
  Vector(x: a.x - b.x, y: a.y - b.y)
}

fn perpendicular(direction: Vector) -> #(Vector, Vector) {
  case direction.x {
    0 -> #(Vector(x: 1, y: 0), Vector(x: -1, y: 0))
    _ -> #(Vector(x: 0, y: 1), Vector(x: 0, y: -1))
  }
}

type Plot =
  String

type Part {
  Part1
  Part2
}

type Edge {
  Edge(edge_position: Vector, empty_position: Vector)
}

fn parse(input: String) -> Dict(Vector, Plot) {
  use map, line, y <- list.index_fold(string.split(input, "\n"), dict.new())
  use map, char, x <- list.index_fold(string.split(line, ""), map)
  dict.insert(map, Vector(x:, y:), char)
}
