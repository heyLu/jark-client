module Installer =
  struct

    open Printf
    open Datatypes
    open Gnet
    open Glist
    open Gstr
    open Gfile
    open Config
    module C = Config

    let cljr_lib () =
      Gfile.path [ C.platform.cljr ; "lib" ]

    let server_jar_url ver ()  =
      let jar =
        sprintf "jark-0.4-SNAPSHOT-clojure-%s-standalone.jar" ver
      in
      let git_base = "https://github.com/downloads/icylisper/jark-server" in
      let url xs = String.concat "/" xs in
      url [git_base; jar]

    (* write out project.clj *)
    let setup_cljr () =
      let file = Gfile.path [C.platform.cljr ; "project.clj"] in
      let f = open_out(file) in
      let project_clj_string = Gstr.unlines [
        "(leiningen.core/defproject cljr.core/cljr-repo";
        "\"1.0.0\"";
        ":description \"cljr is a Clojure REPL and package management system.\"";
        ":dependencies [[org.clojure/clojure \"1.3.0\"]";
        "  [swank-clojure \"1.4.0\"]]";
        "  [org.clojure/java.classpath \"0.1.0\"]]";
        "  [org.clojure/data.json \"0.1.1\"]]";
        "  [org.clojure/tools.namespace \"0.1.0\"]]";
        "  [org.clojure/tools.nrepl \"0.0.5\"]]";
        "  [clj-http \"0.2.7\"]]";
        "  [server-socket \"1.0.0\"]]";
        ":classpath [\"./src/\" \"./\"]";
        ":repositories nil)";
      ]
      in
      fprintf f "%s\n" project_clj_string;
      close_out f

    let install_server () =
      (* check if jar already exists *)
      let o = C.get_server_opts () in
      let install_location = C.server_jar o.install_root o.server_version o.clojure_version () in
      if Gfile.exists install_location then
        Gstr.pe ("Latest version already installed: " ^ install_location)
      else begin
        (* ensure install directories exist *)
        try
          Gfile.mkdir o.install_root;
          Gfile.mkdir (C.cljr_lib o.install_root ());
        with Unix.Unix_error (_, "mkdir" , dir) ->
          raise (Failure ("Permission denied. Could not create directory " ^ dir))

        (* write out project.clj for cljr *)
        setup_cljr ();
        (* download jar *)
        let url = (server_jar_url o.clojure_version ()) in
        Gnet.http_get o.http_client url  install_location;
        Gstr.pe ("Installed server to " ^ install_location)
      end
  end
