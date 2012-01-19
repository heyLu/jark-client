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
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "ns"

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
        0 -> show_usage ()
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

    let ns_list args =
      Jark.nfa "jark.ns" ~f:"list" ~fmt:ResList ()

    let ns_load args = match args with
    [] -> (); Plugin.show_cmd_usage registry "load"
    | x :: xs -> load x

    let _ =
      register_fn "usage" show_usage [];

      register_fn "list" ns_list [
                     " [prefix]" ;
                     "List all namespaces in the classpath. Optionally takes a";
                     "namespace prefix"];

      register_fn "load" ns_load [
                     "[--env=<string>] file" ;
                     "Loads the given clj file, and adds relative classpath"];

      alias_fn "list" ["ls"];
      alias_fn "usage" ["help"]

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      Plugin.dispatch registry cmd arg

  end
