module Ns =
  struct

    open Printf
    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config

    let usage = 
      Gstr.unlines ["usage: jark [options] ns <command> <args>";
                     "Available commands for 'ns' module:\n";
                     "    list      [prefix]" ;
                     "              List all namespaces in the classpath. Optionally takes a namespace prefix\n" ;
                     "    load      [--env=<string>] file" ;
                     "              Loads the given clj file, and adds relative classpath"]

    let load path =
      let apath = (Gfile.abspath path) in
      if (Gfile.exists apath) then
        Jark.nfa "jark.ns" ~f:"load-clj" ~a:[apath] ()
      else begin
        Printf.printf "File not found %s\n" apath;
        ()
      end

    let dispatch cmd arg =
      Config.opts := (Glist.list_to_hashtbl arg);
      Jark.require "jark.ns";
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "list"    -> Jark.nfa "jark.ns" ~f:"list" ()
      | "load"    -> load (Glist.first arg)
      |  _        -> Gstr.pe usage

end
