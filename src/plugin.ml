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

  let get_desc pl name =
    let (f, d) = lookup pl name in
    name :: d

  let show_cmd_usage pl name =
    Gstr.pe (Gstr.unlines (get_desc pl name))


end
