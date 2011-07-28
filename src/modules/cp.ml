module Cp =
  struct

    open Printf
    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config

    let usage = 
      Gstr.unlines ["usage: jark [options] cp <command> <args>";
                     "Available commands for 'cp' module:\n";
                     "    list      List the classpath for the current instance of the JVM\n" ;
                     "    add       path+ [--ignore-jars]" ;
                     "              Add to the classpath for the current instance of the JVM"]

    let do_cp path =
      printf "Adding classpath %s\n" path;
      Jark.nfa "jark.cp" ~f:"add" ~a:[path] ()

    let add_file path =
      let apath = (Gfile.abspath path) in
      if (Gfile.exists apath) then begin
        if (Gfile.isdir apath) then 
          if not ((Config.getopt "--ignore-jars") = "yes") then
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

    let dispatch cmd arg =
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "help"    -> Gstr.pe usage
      | "list"    -> Jark.nfa "jark.cp" ~f:"ls" ()
      | "ls"      -> Jark.nfa "jark.cp" ~f:"ls" ()
      | "add"     -> begin
          let last_arg = Glist.last arg in
          if (Gstr.starts_with last_arg  "--") then
            Config.opts := Glist.list_to_hashtbl [last_arg; "yes"];
          add arg
      end
      |  _        -> Gstr.pe usage

end
