module Cp =
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

    let show_usage args = Plugin.show_usage registry "cp"

    let do_cp path =
      printf "Adding classpath %s\n" path;
      Jark.nfa "jark.cp" ~f:"add" ~a:[path] ()

    let add_file path =
      let apath = (Gfile.abspath path) in
      if (Gfile.exists apath) then begin
        if (Gfile.isdir apath) then 
          if not ((Gopt.getopt "--ignore-jars" ()) = "yes") then
            List.iter (fun x -> do_cp x) (Gfile.glob (sprintf "%s/*.jar" apath));
        do_cp(apath);
        ()
      end
      else begin
        if not (Gstr.starts_with path "--") then
          printf "File not found %s\n" apath
      end

    let add path_list =
      List.iter (fun x -> add_file x) path_list;
      ()

    let list_cp args =
      Jark.nfa "jark.cp" ~f:"ls" ~fmt:ResList ()

    let add_cp args =
      let last_arg = Glist.last args in
      if (Gstr.starts_with last_arg  "--") then
        Gopt.opts := Glist.list_to_hashtbl [last_arg; "yes"];
        add args

    let _ =
      register_fn "list" list_cp
      ["List the classpath for the current instance of the JVM"];

      register_fn "add" add_cp [
        "path+ [--ignore-jars]";
        "Add to the classpath for the current instance of the JVM"];

      register_fn "usage" show_usage [];

      alias_fn "list" ["ls"];
      alias_fn "usage" ["help"]

    let dispatch cmd arg =
      Plugin.dispatch registry cmd arg

end
