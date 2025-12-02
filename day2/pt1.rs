use std::io;

fn is_invalid(id_int: i64) -> bool {
    let id = id_int.to_string();
    if id.len() % 2 != 0 {
        return false;
    }
    let middle = id.len() / 2;
    return &id[..middle] == &id[middle..];
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
                println!("ID {i} is invalid");
                invalid_ids.push(i);
            }
        }
    }
    println!("{}", invalid_ids.into_iter().sum::<i64>());
}
