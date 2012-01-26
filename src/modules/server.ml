module Server =
  struct

    open Datatypes
    open Printf
    open Gstr
    open Glist
    open Jark
    open Config
    module C = Config
    open Options
    open Jvm
    open Plugin
    open Gfile


    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "server"

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


    let install_standalone_jar () =
      let st_jar = (C.jar "standalone") in
      if Gfile.exists st_jar then
        Gstr.pe ("Latest version already installed: " ^ st_jar)
      else
        C.install_standalone ()

    let install args =
      Gfile.mkdir C.cljr;
      Gfile.mkdir C.cljr_lib;
      C.setup_cljr ();
      match C.standalone with
        true -> install_standalone_jar ()
      | false -> C.install_components ();
      Gstr.pe "Installed components successfully"

    let status args =
      try
        let env = C.get_env () in
        Gstr.pe (Gstr.unlines [
          "Connected to JVM";
          "  PID      " ^ Jvm.get_pid ();
          "  Host     " ^ env.host;
          "  Port     " ^ string_of_int env.port])
      with Unix.Unix_error(_, "connect", "") ->
        Gstr.pe "Not connected to JVM"

    let uninstall args =
      Gstr.pe "Removed jark configs successfully"

    let _ =
      register_fn "start" Jvm.start [
        "[-p|--port=<9000>] [-j|--jvm-opts=<opts>] [--log=<path>]" ;
        "Start a local Jark server. Takes optional JVM options as a \" delimited string"];

      register_fn "stop" Jvm.stop [
        "[-n|--name=<vm-name>]";
        "Shuts down the current instance of the JVM"];

      register_fn "load" ns_load [
      "[--env=<string>] file" ;
        "Loads the given clj file, and adds relative classpath"];

      register_fn "status" status ["Display connection status"];

      register_fn "install" uninstall ["Install server components"]


    let dispatch cmd args =
      match cmd with
      | "start"      -> Jvm.start args
      | "stop"       -> Jvm.stop args
      | "load"       -> ns_load args
      | "install"    -> install args
      | "status"     -> status args
      | _            -> Jark.nfa "jark.vm" ~f:cmd ~a:args ()

end
