import gleam/list

pub fn index_find(list, f) {
  do_index_find(list, f, 0)
}

fn do_index_find(list, f, i) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] ->
      case f(first, i) {
        True -> Ok(first)
        _ -> do_index_find(rest, f, i + 1)
      }
  }
}

pub fn index_find_map(list, f) {
  do_index_find_map(list, f, 0)
}

fn do_index_find_map(list, f, i) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] ->
      case f(first, i) {
        Ok(v) -> Ok(v)
        _ -> do_index_find_map(rest, f, i + 1)
      }
  }
}

pub fn at(list, i) {
  list |> index_find(fn(_, index) { index == i })
}

pub fn index_of(list, value) {
  list
  |> index_find_map(fn(v, i) {
    case v == value {
      True -> Ok(i)
      False -> Error(Nil)
    }
  })
}

pub fn not(f) {
  fn(a) { !f(a) }
}

pub fn insert(list, index, value) {
  let #(before, after) = list.split(list, index)
  list.flatten([before, [value], after])
}
