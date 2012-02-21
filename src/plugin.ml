module Plugin = struct
  open Printf
  open Gstr

  type registry = (string, ((string list -> unit) * string list)) Hashtbl.t
  type aliases = (string, string list) Hashtbl.t

  let create () = (Hashtbl.create 4, Hashtbl.create 4)

  let register_fn (reg, al) name fn desc = Hashtbl.add reg name (fn, desc)

  let alias_fn (reg, al) name alts =
    if (not (Hashtbl.mem reg name)) then
      raise Not_found (*(sprintf "No such function %s" name)*);
    List.iter (fun x -> Hashtbl.add al x name) alts

  let lookup (reg, al) name =
    try
      let a = Hashtbl.find al name in
      Hashtbl.find reg a
    with Not_found -> Hashtbl.find reg name

  let dispatch pl name args =
    let (f, d) = lookup pl name in
    f args

  (* TODO: handle tabular formatting properly *)
  let get_desc pl name =
    let (f, d) = lookup pl name in
    match d with
    [] -> []
    | x :: xs -> ("\t" ^ name ^ "\t" ^ x) :: (List.map (fun x -> "\t\t" ^ x) xs)

  let show_cmd_usage pl name =
    Gstr.pe (Gstr.unlines (get_desc pl name))

  let append_usage pl acc name =
    let d = get_desc pl name in
    match d with
      [] -> acc
    | _  -> acc ^ "\n" ^ (Gstr.unlines d) ^ "\n"

  let get_usage pl m =
    let (reg, al) = pl in
    let pref = Gstr.unlines [
      "usage: jark " ^ m ^ " <command> <args> [options]\n";
      "Available commands for module " ^ m ^ ":"] in
    Hashtbl.fold (fun k v a -> append_usage pl a k) reg pref

  let show_usage pl m = Gstr.pe (get_usage pl m)

end
