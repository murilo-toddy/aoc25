import gleam/list

import input

import pt1
import pt2

fn read_input_rec(in: List(String)) -> List(String) {
    case input.input("") {
        Ok("") | Error(Nil) -> list.reverse(in)
        Ok(line) -> read_input_rec([line, ..in])
    }
}

fn read_input() -> List(String) {
    read_input_rec([])
}

pub fn main() {
    let input = read_input()
    // pt1.solve(input)
    pt2.solve(input)
}

