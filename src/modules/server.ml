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
    open Installer


    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "server"

    let load path =
      let apath = (Gfile.abspath path) in
      if (Gfile.exists apath) then
        Jark.nfa "clojure.tools.jark.plugin.ns" ~f:"load" ~a:[apath] ()
      else begin
        Printf.printf "File not found %s\n" apath;
        ()
      end

    let ns_load args = match args with
    [] -> (); Plugin.show_cmd_usage registry "load"
    | x :: xs -> load x

    let install_standalone_jar () =
      let st_jar = (Installer.jar "standalone") in
      if Gfile.exists st_jar then
        Gstr.pe ("Latest version already installed: " ^ st_jar)
      else
        Installer.install_standalone ()

    let install args =
      Installer.read_config ();
      Glist.print_list args;
      Gfile.mkdir Installer.conf.install_root;
      Gfile.mkdir (Installer.cljr_lib ());
      Installer.setup_cljr ();
      match C.standalone with
        true -> install_standalone_jar ()
      | false -> Installer.install_components ();
      Gstr.pe "Installed components successfully"

    let uninstall args =
      Gstr.pe "Removed jark configs successfully"

    let info args =
      Jark.nfa "clojure.tools.jark.server" ~f:"info" ~a:args ()

    let clients args = 
      Jark.nfa "clojure.tools.jark.server" ~f:"clients" ~a:args ()

    let version args = 
      Jark.nfa "clojure.tools.jark.server" ~f:"version" ~a:args ()

    let stop args = 
      Jark.nfa "clojure.tools.jark.server" ~f:"stop" ~a:args ()

    let _ =
      register_fn "start" Jvm.start [
        "[-p|--port=<9000>] [-j|--jvm-opts=<opts>] [--log=<path>]" ;
        "Start a local Jark server. Takes optional JVM options as a \" delimited string"];

      register_fn "stop" Jvm.stop [
        "[-n|--name=<vm-name>]";
        "Shuts down the current instance of the JVM (Run only on the server)"];

      register_fn "load" ns_load [
      "[--env=<string>] file" ;
        "Loads the given clj file, and adds relative classpath"];

      register_fn "install" install [
      "[--prefix=<path> (default:~/.cljr)] [--standalone=<true|false> (default:true)] [--force=<true|false> (default:false)]";
      "Install server components"];
      
      register_fn "info" info ["Display Jark server information"];

      register_fn "clients" clients ["Display all clients connected to this server"]

    let dispatch cmd args =
      match cmd with
      | "info"       -> info args
      | "clients"    -> clients args
      | "install"    -> install args
      | "load"       -> ns_load args
      | "start"      -> Jvm.start args
      | "stop"       -> Jvm.stop args
      | "version"    -> version args
      | _            -> Jark.nfa "clojure.tools.jark.server" ~f:cmd ~a:args ()

end
