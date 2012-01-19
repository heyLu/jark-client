module Self =
  struct

    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config
    module C = Config
    open Stat
    open Gopt
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "self"

    let install_standalone_jar () =
      let st_jar = (C.jar "standalone") in
      if Gfile.exists st_jar then
        Gstr.pe (st_jar ^ " already exists")
        (* TODO: why do we care? *)
      else
        C.install_standalone ()

    let install args =
      let mkdir dir =
        try Unix.mkdir dir 0o740 with Unix.Unix_error (Unix.EEXIST,_,_) -> ()
      in
      mkdir Config.cljr;
      mkdir C.cljr_lib;
      C.setup_cljr ();
      match C.standalone with
        true -> install_standalone_jar ()
      | false -> C.install_components ();
      Gstr.pe "Installed components successfully"

    let status args =
      let host = Gopt.getopt "--host" () in
      let port = Gopt.getopt "--port" () in
      Gstr.pe (Gstr.unlines ["PID      " ^ Stat.get_pid ();
                             "Host     " ^ host;
                             "Port     " ^ port])

    let uninstall args =
      Gstr.pe "Removed jark configs successfully"

    let _ =
      register_fn "install" install [
        "[--no-standalone] [--force]";
        "Install jark"];

      register_fn "status" status ["VM connection status"];

      register_fn "uninstall" uninstall ["Uninstall jark"]

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      Plugin.dispatch registry cmd arg

end
