module Ns =
  struct

    open Datatypes
    open Printf
    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config
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

    let ns_load args = match args with
    [] -> (); Plugin.show_cmd_usage registry "load"
    | x :: xs -> load x

    let _ =
      register_fn "load" ns_load [
                     "[--env=<string>] file" ;
                     "Loads the given clj file, and adds relative classpath"]

    let dispatch cmd args =
      match cmd with
      | "load" -> ns_load args
      | _      -> Jark.nfa "jark.ns" ~f:cmd ~a:args ()

  end
