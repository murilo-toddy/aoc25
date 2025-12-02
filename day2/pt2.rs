use std::io;

fn is_invalid(id_int: i64) -> bool {
    let id_str = id_int.to_string();
    let id = id_str.as_bytes();
    if id.len() == 1 {
        return false;
    }
    let mut pattern_size = 1;
    loop {
        // two pointers
        let mut current_idx = pattern_size;
        let mut pattern_idx = 0;
        while current_idx < id.len() && id[current_idx] == id[pattern_idx] {
            current_idx += 1;
            pattern_idx = (pattern_idx + 1) % pattern_size;
        }
        if current_idx == id.len() && pattern_idx == 0 {
            let mut slices = Vec::new();
            for i in (0..id_str.len()).step_by(pattern_size) {
                slices.push(&id_str[i..i + pattern_size]);
            }
            println!("ID {id_str} is invalid pattern:\t{:?}", slices);
            return true;
        }
        pattern_size += 1;
        if pattern_size > id.len() / 2 {
            return false;
        }
    }
}

fn main() {
    let mut line = String::new();
    io::stdin()
        .read_line(&mut line)
        .expect("should be able to read line from stdin");

    if line.ends_with("\n") {
        line.pop();
    }
    let ranges = line.split(",").collect::<Vec<_>>();
    let mut invalid_ids: Vec<i64> = Vec::new();

    for range in &ranges {
        let range_parts = range.splitn(2, "-").collect::<Vec<_>>();
        if range_parts.len() != 2 {
            eprintln!("got invalid range {:?}", range_parts);
        }
        let stoi = |v: &str| -> i64 { v.parse().expect("should be valid integer") };
        for i in stoi(range_parts[0])..stoi(range_parts[1]) + 1 {
            if is_invalid(i) {
                invalid_ids.push(i);
            }
        }
    }
    println!("{}", invalid_ids.into_iter().sum::<i64>());
}
