import aoc/utils
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let disk = parse(input)
  use count, position, file <- dict.fold(
    rearrange_blocks(disk.files, disk.empty, dict.new()),
    0,
  )
  count + position * file.id
}

fn rearrange_blocks(
  files: Deque(FileBlock),
  empty: Deque(Int),
  acc: Dict(Int, FileBlock),
) -> Dict(Int, FileBlock) {
  case deque.pop_back(files) {
    Error(_) -> acc
    Ok(#(file, rest_files)) ->
      case deque.pop_front(empty) {
        Ok(#(empty, rest_empty)) if empty < file.position -> {
          rearrange_blocks(
            rest_files,
            rest_empty,
            dict.insert(acc, empty, file),
          )
        }
        _ ->
          files
          |> deque.to_list
          |> list.map(fn(file) { #(file.position, file) })
          |> dict.from_list
          |> dict.merge(acc)
      }
  }
}

fn parse(input: String) -> Disk(FileBlock, Int) {
  use disk, char, i <- list.index_fold(
    string.to_graphemes(input),
    Disk(deque.new(), deque.new(), 0, 0),
  )
  let assert Ok(size) = int.parse(char)
  case int.is_even(i) {
    True -> {
      let files =
        list.fold(list.range(0, size - 1), disk.files, fn(queue, position) {
          FileBlock(id: disk.file_count, position: disk.size + position)
          |> deque.push_back(queue, _)
        })
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
          list.fold(
            list.range(disk.size, disk.size + size - 1),
            disk.empty,
            deque.push_back,
          )
      }
      Disk(..disk, empty:, size: disk.size + size)
    }
  }
}

type FileBlock {
  FileBlock(id: Int, position: Int)
}

type Disk(file, empty) {
  Disk(files: Deque(file), empty: Deque(empty), size: Int, file_count: Int)
}

pub fn pt_2(input: String) -> Int {
  let disk = parse_whole_files(input)
  use count, position, file <- dict.fold(
    rearrange_whole_files(disk.files, deque.to_list(disk.empty), dict.new()),
    0,
  )
  count + file_checksum(file, position)
}

fn file_checksum(file: File, position: Int) -> Int {
  list.range(position, position + file.size - 1)
  |> list.map(fn(a) { a * file.id })
  |> int.sum
}

fn rearrange_whole_files(
  files: Deque(File),
  empty: List(EmptyBlock),
  acc: Dict(Int, File),
) -> Dict(Int, File) {
  case deque.pop_back(files) {
    Error(_) -> acc
    Ok(#(file, rest)) -> {
      let found =
        utils.find_with_index(empty, fn(empty) {
          empty.start < file.start && empty.size >= file.size
        })
      case found {
        Ok(#(empty_space, i)) -> {
          let assert Ok(empty) = case empty_space.size - file.size {
            0 -> utils.remove(empty, i)
            _ ->
              utils.set(
                empty,
                i,
                EmptyBlock(
                  size: empty_space.size - file.size,
                  start: empty_space.start + file.size,
                ),
              )
          }
          rearrange_whole_files(
            rest,
            empty,
            dict.insert(acc, empty_space.start, file),
          )
        }
        Error(_) ->
          rearrange_whole_files(rest, empty, dict.insert(acc, file.start, file))
      }
    }
  }
}

fn parse_whole_files(input: String) -> Disk(File, EmptyBlock) {
  use disk, char, i <- list.index_fold(
    string.to_graphemes(input),
    Disk(deque.new(), deque.new(), 0, 0),
  )
  let assert Ok(size) = int.parse(char)
  case int.is_even(i) {
    True -> {
      let files =
        deque.push_back(
          disk.files,
          File(start: disk.size, id: disk.file_count, size:),
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
        _ -> deque.push_back(disk.empty, EmptyBlock(start: disk.size, size:))
      }
      Disk(..disk, empty:, size: disk.size + size)
    }
  }
}

type File {
  File(start: Int, id: Int, size: Int)
}

type EmptyBlock {
  EmptyBlock(start: Int, size: Int)
}
