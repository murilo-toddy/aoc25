let all_input = In_channel.input_all In_channel.stdin;;
let start_pos = 50;;

let lines = String.split_on_char '\n' all_input |> List.filter (fun l -> String.length l > 0);;

let move (pos, count: int * int) (line: string): (int * int) =
    let op = match String.get line 0 with
    | 'R' -> (+)
    | 'L' -> (-)
    | _ -> failwith "got invalid operation"
    in
    let n = match String.sub line 1 (String.length line - 1) |> int_of_string_opt with
    | Some n -> n
    | None -> failwith "got invalid number"
    in
    let full_rotations = Int.abs n / 100 in
    let new_pos = op pos (n - 100 * full_rotations) in
    let click = (pos != 0 && new_pos <= 0) || new_pos >= 100 in
    let rotations = full_rotations + if click then 1 else 0 in
    let new_pos_mod = new_pos mod 100 in
    let new_pos_corrected = if new_pos_mod < 0 then new_pos_mod + 100 else new_pos_mod in
    let _ = line ^ 
            "\tPosition before: " ^ string_of_int pos ^ 
            "\tZero count before: " ^ string_of_int count ^
            "\tMoving " ^ line ^
            "\tPosition after: " ^ string_of_int new_pos ^
            "\tFull rotations: " ^ string_of_int full_rotations ^
            "\tClick: " ^ string_of_bool click ^
            "\tNew count: " ^ string_of_int (count + rotations) ^
            "\tFinal position: " ^ string_of_int new_pos_corrected
            |> print_endline
    in
    new_pos_corrected, count + rotations
in

let (final_pos, final_count) = List.fold_left move (start_pos, 0) lines in
string_of_int final_count |> print_endline;;

