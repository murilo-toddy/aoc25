let all_input = In_channel.input_all In_channel.stdin;;
let start_pos = 50;;

let lines = String.split_on_char '\n' all_input |> List.filter (fun l -> String.length l > 0);;
List.map (fun l -> "line: " ^ l ^ "\n" |> print_string) lines;;

let move (pos, count: int * int) (line: string): (int * int) =
    let _ = line ^ 
            "\tCurrent position " ^ string_of_int pos ^ 
            "\tZero count " ^ string_of_int count 
            |> print_endline
    in
    let op = match String.get line 0 with
    | 'R' -> (+)
    | 'L' -> (-)
    | _ -> failwith "got invalid operation"
    in
    let n = match String.sub line 1 (String.length line - 1) |> int_of_string_opt with
    | Some n -> n
    | None -> failwith "got invalid number"
    in
    let newpos = op pos n mod 100 in
    let newcount = if newpos = 0 then count + 1 else count in
    newpos, newcount
in

let (final_pos, final_count) = List.fold_left move (start_pos, 0) lines in
string_of_int final_count |> print_endline;;
