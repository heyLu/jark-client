module Options = struct
  open Datatypes
  open Printf

  exception BadOptions of string

  type opt =
    Set_on of bool ref 
  | Set_off of bool ref 
  | Set_string of string ref
  | Set_int of int ref 
  | Unknown

  let set_string x y = x := y

  let set_int x y =
    try
      x := int_of_string y
    with Failure "int_of_string" -> raise (BadOptions ("Not a number: " ^ y))

  let set_on x = x := true

  let set_off x = x := false

  let lookup_opt x args =
    try
      let (p, q, r) = List.find (fun (i, j, k) -> i = x) args in q
    with Not_found -> Unknown

  let parse args opts =
    let lookup x = lookup_opt x opts in
    let rec optparse os =
      match os with
        [] -> []
      | x :: xs -> match ((lookup x), xs) with
          Set_on v, _           -> (set_on v; optparse xs)
        | Set_off v, _          -> (set_off v; optparse xs)
        | Set_string v, []      -> raise (BadOptions ("missing argument to " ^ x))
        | Set_int v, []         -> raise (BadOptions ("missing argument to " ^ x))
        | Set_string v, y :: ys -> (set_string v y; optparse ys)
        | Set_int v, y :: ys    -> (set_int v y; optparse ys)
        | Unknown, _ -> if x.[0] = '-' then
          raise (BadOptions ("unknown option " ^ x))
          else (x :: xs)
    in
    optparse args

  let parse_argv opts =
    let args = List.tl (Array.to_list Sys.argv) in
    parse args opts

end
