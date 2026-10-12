(* Loaded before every exercise: assertion helpers the checks share. *)
module Check = struct
  let failures = ref 0

  let fail name detail =
    incr failures;
    print_endline ("FAIL " ^ name ^ detail)

  let ok name cond = if not cond then fail name ""

  let eq show name got want =
    if got <> want then
      fail name (Printf.sprintf "\n  expected %s\n  got      %s" (show want) (show got))

  let int = eq string_of_int
  let str = eq (Printf.sprintf "%S")
  let bool = eq string_of_bool
  let char = eq (Printf.sprintf "%C")

  let float name got want =
    if Float.abs (got -. want) > 1e-9 then
      fail name (Printf.sprintf "\n  expected %g\n  got      %g" want got)

  let list show = eq (fun l -> "[" ^ String.concat "; " (List.map show l) ^ "]")
  let ints = list string_of_int
  let strs = list (Printf.sprintf "%S")
  let opt show = eq (function None -> "None" | Some x -> "Some " ^ show x)

  let result show =
    eq (function Ok x -> "Ok " ^ show x | Error e -> Printf.sprintf "Error %S" e)

  let raises name f =
    match f () with
    | _ -> fail name "\n  expected an exception, but none was raised"
    | exception _ -> ()

  let finish () = if !failures > 0 then exit 1
end
