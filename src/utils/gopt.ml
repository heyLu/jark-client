(*pp $PP *)

module Gopt =
  struct

    open Printf
    open Datatypes
    open Gsys
    open Gnet
    open Glist
    open Gstr

    let opts = ref ((Hashtbl.create 0) : (string, string) Hashtbl.t)

    let default_opts = ref ((Hashtbl.create 0) : (string, string list) Hashtbl.t)

    let get_alias opt_name () =
      let h = !default_opts in
      if (Hashtbl.mem h opt_name) then
        (Glist.first (Hashtbl.find h opt_name))
      else
        "nil"

    let get_default opt_name () =
      let h = !default_opts in
      if (Hashtbl.mem h opt_name) then
        (Glist.last (Hashtbl.find h opt_name))
      else
        "nil"

    let getopt opt_name () =
      let alias = get_alias opt_name () in
      let h = !opts in 
      if (Hashtbl.mem h opt_name) then
        Hashtbl.find h opt_name
      else if (Hashtbl.mem h alias) then
        Hashtbl.find h alias
      else
        get_default opt_name ()

end
