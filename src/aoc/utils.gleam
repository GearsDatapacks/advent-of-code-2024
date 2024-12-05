import gleam/list

pub fn index_find(list: List(a), f: fn(a, Int) -> Bool) -> Result(a, Nil) {
  do_index_find(list, f, 0)
}

fn do_index_find(list: List(a), f: fn(a, Int) -> Bool, i: Int) -> Result(a, Nil) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] ->
      case f(first, i) {
        True -> Ok(first)
        _ -> do_index_find(rest, f, i + 1)
      }
  }
}

pub fn index_find_map(list: List(a), f: fn(a, Int) -> Result(b, c)) -> Result(b, Nil) {
  do_index_find_map(list, f, 0)
}

fn do_index_find_map(list: List(a), f: fn(a, Int) -> Result(b, c), i: Int) -> Result(b, Nil) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] ->
      case f(first, i) {
        Ok(v) -> Ok(v)
        _ -> do_index_find_map(rest, f, i + 1)
      }
  }
}

pub fn at(list: List(a), i: Int) -> Result(a, Nil) {
  list |> index_find(fn(_, index) { index == i })
}

pub fn index_of(list: List(a), value: a) -> Result(Int, Nil) {
  list
  |> index_find_map(fn(v, i) {
    case v == value {
      True -> Ok(i)
      False -> Error(Nil)
    }
  })
}

pub fn not(f: fn(a) -> Bool) -> fn(a) -> Bool {
  fn(a) { !f(a) }
}

pub fn insert(list: List(a), index: Int, value: a) -> List(a) {
  let #(before, after) = list.split(list, index)
  list.flatten([before, [value], after])
}

pub fn unwrap(result: Result(ok, error)) -> ok {
  let assert Ok(inner) = result
  inner
}
