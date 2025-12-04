import gleam/dict.{type Dict}
import gleam/list
import gleam/int
import gleam/io
import gleam/option.{type Option, Some, None}
import gleam/pair
import gleam/string

type Grid = Dict(#(Int, Int), Bool)

fn to_bool(input: List(String)) -> Grid {
    list.index_map(input, fn(line, row) {
        list.index_map(string.to_graphemes(line), fn(element, col) {
            case element {
                "@" -> #(#(row, col), True)
                "." -> #(#(row, col), False)
                _ -> panic as "invalid input cell"
            }
        })
    }) |> list.flatten |> dict.from_list
}

fn count_neighbors(in: Grid, row: Int, col: Int) -> Int {
    let directions = [-1, 0, 1]
    let neighbors = list.map(directions, fn(dir1) {
        list.map(directions, fn(dir2) { #(dir1, dir2) })
    }) |> list.flatten
    let neighbors_count = list.map(neighbors, fn(dir) {
        case dir {
            #(0, 0) -> 0
            #(dr, dc) -> {
                case dict.get(in, #(row + dr, col + dc)) {
                    Ok(True) -> 1
                    _ -> 0
                }
            }
        }
    })
    list.fold(neighbors_count, 0, fn(i, acc) { acc + i })
}

// returns new grid and number of rolls removed
fn count_rolls_rec(grid: Grid, row: Int, col: Int, acc: Int, rows: Int, cols: Int) -> #(Grid, Int) {
    let accessible = fn(grid, row, col) {
        case dict.get(grid, #(row, col)) {
            Ok(True) -> {
                case count_neighbors(grid, row, col) {
                    n if n < 4 -> {
                        // instantly remove it
                        #(dict.insert(grid, #(row, col), False), 1)
                    }
                    _ -> #(grid, 0)
                }
            }
            _ -> #(grid, 0)
        }
    }
    case #(row, col) {
        #(row, col) if row < rows && col < cols -> {
            let #(new_grid, count) = accessible(grid, row, col)
            count_rolls_rec(new_grid, row, col + 1, acc + count, rows, cols)
        }
        #(row, col) if row < rows && col >= cols -> {
            let #(new_grid, count) = accessible(grid, row, col)
            count_rolls_rec(new_grid, row + 1, 0, acc + count, rows, cols)
        }
        _ if acc > 0 -> {
            // if rolls got removed, count removable again
            let #(new_grid, new_acc) = count_rolls_rec(grid, 0, 0, 0, rows, cols)
            #(new_grid, acc + new_acc)
        }
        _ -> #(grid, acc)
    }
}

fn count_rolls(grid: Grid, rows: Int, cols: Int) -> #(Grid, Int) {
    count_rolls_rec(grid, 0, 0, 0, rows, cols)
}

pub fn solve(input: List(String)) {
    let rows = list.length(input)
    let cols = case list.first(input) {
        Ok(r) -> string.length(r)
        _ -> panic as "first row is empty"
    }
    let grid = input |> to_bool
    echo count_rolls(grid, rows, cols)
}
