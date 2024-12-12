import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn pt_1(input: String) {
  let map = parse(input)
  calculate_fences(map, dict.keys(map), 0)
}

fn calculate_fences(map, positions, sum) {
  case positions {
    [] -> sum
    [position, ..positions] ->
      case dict.get(map, position) {
        Ok(plot) -> {
          let #(map, cost) = calculate_cost(map, position, plot)
          calculate_fences(map, positions, sum + cost)
        }
        Error(_) -> calculate_fences(map, positions, sum)
      }
  }
}

fn calculate_cost(map, position, plot) {
  let #(map, region) = find_region(map, position, plot, dict.new())
  let area = dict.size(region)
  let #(map, perimeter) =
    dict.fold(region, #(map, 0), fn(acc, position, adjacent) {
      let #(map, perimeter) = acc
      #(dict.delete(map, position), perimeter + 4 - adjacent)
    })
  #(map, area * perimeter)
}

fn find_region(map, position, plot, region) {
  use <- bool.guard(dict.has_key(region, position), #(map, region))
  let region = dict.insert(region, position, 0)
  let #(map, region, count) = {
    use #(map, region, count), direction <- list.fold(directions, #(
      map,
      region,
      0,
    ))
    let position = add(position, direction)
    case dict.get(map, position) {
      Ok(p) if p == plot -> {
        let #(map, region) = find_region(map, position, plot, region)
        #(map, region, count + 1)
      }
      _ -> #(map, region, count)
    }
  }
  #(map, dict.insert(region, position, count))
}

const directions = [
  Position(r: 1, c: 0),
  Position(r: -1, c: 0),
  Position(r: 0, c: 1),
  Position(r: 0, c: -1),
]

pub fn pt_2(input: String) {
  let map = parse(input)
  calculate_fences2(map, dict.keys(map), 0)
}

fn calculate_fences2(map, positions, sum) {
  case positions {
    [] -> sum
    [position, ..positions] ->
      case dict.get(map, position) {
        Ok(plot) -> {
          let #(map, cost) = calculate_cost2(map, position, plot)
          calculate_fences2(map, positions, sum + cost)
        }
        Error(_) -> calculate_fences2(map, positions, sum)
      }
  }
}

fn calculate_cost2(map, position, plot) {
  let #(map, region, edges) =
    find_region2(map, position, plot, set.new(), set.new())
  let area = set.size(region)
  let map =
    set.fold(region, map, fn(map, position) { dict.delete(map, position) })
  let perimeter = calculate_perimeter(edges, 0)
  #(map, area * perimeter)
}

fn find_region2(
  map: Dict(Position, a),
  position: Position,
  plot: a,
  region: Set(Position),
  edges: Set(Edge),
) -> #(Dict(Position, a), Set(Position), Set(Edge)) {
  use <- bool.guard(set.contains(region, position), #(map, region, edges))
  let region = set.insert(region, position)
  let #(map, region, edges) = {
    use #(map, region, edges), direction <- list.fold(directions, #(
      map,
      region,
      edges,
    ))
    let new_position = add(position, direction)
    case dict.get(map, new_position) {
      Ok(p) if p == plot -> {
        let #(map, region, edges) =
          find_region2(map, new_position, plot, region, edges)
        #(map, region, edges)
      }
      _ -> #(map, region, set.insert(edges, Edge(position, new_position)))
    }
  }
  #(map, set.insert(region, position), edges)
}

fn calculate_perimeter(edges: Set(Edge), count) {
  case set.to_list(edges) {
    [] -> count
    [edge, ..] -> {
      let edges = trace_edge(edges, edge)
      calculate_perimeter(edges, count + 1)
    }
  }
}

fn trace_edge(edges: Set(Edge), edge) {
  use <- bool.guard(!set.contains(edges, edge), edges)
  let edges = set.delete(edges, edge)
  let direction = sub(edge.edge_position, edge.empty_position)
  let #(a, b) = perpendicular(direction)
  let edge1 = Edge(add(edge.edge_position, a), add(edge.empty_position, a))
  let edge2 = Edge(add(edge.edge_position, b), add(edge.empty_position, b))
  edges |> trace_edge(edge1) |> trace_edge(edge2)
}

type Position {
  Position(r: Int, c: Int)
}

fn add(a: Position, b: Position) {
  Position(r: a.r + b.r, c: a.c + b.c)
}

fn sub(a: Position, b: Position) {
  Position(r: a.r - b.r, c: a.c - b.c)
}

fn perpendicular(direction: Position) {
  case direction.r {
    0 -> #(Position(r: 1, c: 0), Position(r: -1, c: 0))
    _ -> #(Position(r: 0, c: 1), Position(r: 0, c: -1))
  }
}

type Edge {
  Edge(edge_position: Position, empty_position: Position)
}

fn parse(input) {
  use map, line, r <- list.index_fold(string.split(input, "\n"), dict.new())
  use map, char, c <- list.index_fold(string.split(line, ""), map)
  dict.insert(map, Position(r:, c:), char)
}
