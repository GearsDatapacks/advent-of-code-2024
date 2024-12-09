import gleam/dict
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let disk = parse(input)
  use count, position, file <- dict.fold(
    rearrange(disk.files, list.reverse(disk.empty), dict.new()),
    0,
  )
  count + position * file.id
}

fn rearrange(files: List(FileBlock), empty, acc) {
  case files, empty {
    [], _ -> acc
    [file, ..], [empty, ..] if file.position < empty ->
      list.map(files, fn(file) { #(file.position, file) })
      |> dict.from_list
      |> dict.merge(acc)

    _, [] ->
      list.map(files, fn(file) { #(file.position, file) })
      |> dict.from_list
      |> dict.merge(acc)

    [file, ..rest_files], [empty, ..rest_empty] ->
      rearrange(rest_files, rest_empty, dict.insert(acc, empty, file))
  }
}

fn parse(input: String) {
  use disk, char, i <- list.index_fold(
    string.to_graphemes(input),
    Disk([], [], 0, 0),
  )
  let assert Ok(size) = int.parse(char)
  case int.is_even(i) {
    True -> {
      let files =
        list.append(
          list.map(list.range(size - 1, 0), fn(position) {
            FileBlock(id: disk.file_count, position: disk.size + position)
          }),
          disk.files,
        )
      Disk(
        ..disk,
        files:,
        size: disk.size + size,
        file_count: disk.file_count + 1,
      )
    }
    False -> {
      let empty = case size {
        0 -> disk.empty
        _ ->
          list.append(list.range(disk.size + size - 1, disk.size), disk.empty)
      }
      Disk(..disk, empty:, size: disk.size + size)
    }
  }
}

type FileBlock {
  FileBlock(id: Int, position: Int)
}

type Disk {
  Disk(files: List(FileBlock), empty: List(Int), size: Int, file_count: Int)
}

pub fn pt_2(input: String) {
  let disk = parse2(input)
  use count, position, file <- dict.fold(
    rearrange2(disk.files, list.reverse(disk.empty), dict.new()),
    0,
  )
  count + file_score(file, position)
}

fn file_score(file: File, position) {
  list.range(position, position + file.size - 1)
  |> list.map(fn(a) { a * file.id })
  |> int.sum
}

fn rearrange2(files: List(File), empty: List(Empty), acc) {
  case files {
    [] -> acc
    [file, ..rest] -> {
      let found =
        list.find(empty, fn(empty) {
          empty.start < file.start && empty.size >= file.size
        })
      case found {
        Ok(empty_space) -> {
          let new_space =
            Empty(
              size: empty_space.size - file.size,
              start: empty_space.start + file.size,
            )
          let empty = case new_space.size {
            0 ->
              list.filter(empty, fn(empty) { empty.start != empty_space.start })
            _ ->
              list.map(empty, fn(empty) {
                case empty.start == empty_space.start {
                  True -> new_space
                  False -> empty
                }
              })
          }
          rearrange2(
            rest,
            empty,
            dict.insert(acc, empty_space.start, file),
          )
        }
        Error(_) -> rearrange2(rest, empty, dict.insert(acc, file.start, file))
      }
    }
  }
}

fn parse2(input: String) {
  use disk, char, i <- list.index_fold(
    string.to_graphemes(input),
    Disk2([], [], 0, 0),
  )
  let assert Ok(size) = int.parse(char)
  case int.is_even(i) {
    True -> {
      let files = [
        File(start: disk.size, id: disk.file_count, size:),
        ..disk.files
      ]
      Disk2(
        ..disk,
        files:,
        size: disk.size + size,
        file_count: disk.file_count + 1,
      )
    }
    False -> {
      let empty = case size {
        0 -> disk.empty
        _ -> [Empty(start: disk.size, size:), ..disk.empty]
      }
      Disk2(..disk, empty:, size: disk.size + size)
    }
  }
}

type File {
  File(start: Int, id: Int, size: Int)
}

type Empty {
  Empty(start: Int, size: Int)
}

type Disk2 {
  Disk2(files: List(File), empty: List(Empty), size: Int, file_count: Int)
}
