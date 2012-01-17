module Ns =
  struct

    open Datatypes
    open Printf
    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config
    open Gopt

    let usage = 
      Gstr.unlines ["usage: jark [options] ns <command> <args>";
                     "Available commands for 'ns' module:\n";
                     "    list      [prefix]" ;
                     "              List all namespaces in the classpath. Optionally takes a namespace prefix\n" ;
                     "    load      [--env=<string>] file" ;
                     "              Loads the given clj file, and adds relative classpath"]

    let show_usage () = Gstr.pe usage

    let load path =
      let apath = (Gfile.abspath path) in
      if (Gfile.exists apath) then
        Jark.nfa "jark.ns" ~f:"load-clj" ~a:[apath] ()
      else begin
        Printf.printf "File not found %s\n" apath;
        ()
      end

    let dispatch_nfa al = 
      let arg = ref [] in
      let last_arg = Glist.last al in
      if (Gstr.starts_with last_arg  "--") then begin
        Gopt.opts := Glist.list_to_hashtbl [last_arg; "yes"];
        arg := (Glist.remove_last al)
      end
      else
        arg := al;
      let xs = !arg in
      match (List.length xs) with 
        0 -> Gstr.pe usage
      | 1 -> Jark.nfa (List.nth xs 0) ()
      | 2 -> Jark.nfa  (List.nth xs 0) ~f:(List.nth xs 1) ()
      | _ -> Jark.nfa (List.nth xs 0) ~f:(List.nth xs 1) ~a:(Glist.drop 2 xs) ()

    let run xs =
      let file = (Glist.first xs) in
      if (Gfile.exists file) then begin
        load file;
      end
      else 
        dispatch_nfa xs

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "list"    -> Jark.nfa "jark.ns" ~f:"list" ~fmt:ResList ()
      | "load"    -> load (Glist.first arg)
      |  _        -> Gstr.pe usage

end
