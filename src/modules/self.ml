module Self =
  struct

    open Glist
    open Gstr
    open Gfile
    open Jark
    open Config
    module C = Config
    open Stat
    open Plugin
    open Datatypes

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
      Gfile.mkdir Config.cljr;
      Gfile.mkdir C.cljr_lib;
      C.setup_cljr ();
      match C.standalone with
        true -> install_standalone_jar ()
      | false -> C.install_components ();
      Gstr.pe "Installed components successfully"

    let status args =
      let env = C.get_env () in
      Gstr.pe (Gstr.unlines ["PID      " ^ Stat.get_pid ();
                             "Host     " ^ env.host;
                             "Port     " ^ string_of_int env.port])

    let uninstall args =
      Gstr.pe "Removed jark configs successfully"

    let _ =
      register_fn "install" install [
        "[--no-standalone] [--force]";
        "Install jark"];

      register_fn "status" status ["VM connection status"];

      register_fn "uninstall" uninstall ["Uninstall jark"]

    let dispatch cmd arg =
      Plugin.dispatch registry cmd arg

end
