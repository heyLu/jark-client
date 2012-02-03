module Installer =
  struct

    open Printf
    open Datatypes
    open Gsys
    open Gnet
    open Glist
    open Gstr
    open Gfile
    open Gconf
    open Config
    module C = Config

    let conf = {
      install_root = C.platform.cljr;
      http_client = C.platform.wget_bin;
      clojure_version = "1.3.0"
    }

    let cljr_lib () =
      Gfile.path [ conf.install_root ; "lib" ]

    let set_install_opt k v = match k with
    | "install_root"    -> conf.install_root <- v
    | "http_client"     -> conf.http_client <- v
    | "clojure_version" -> conf.clojure_version <- v
    | _                  -> ()

    let read_config () = C.read_config_file set_install_opt

    let standalone_jar = 
      let clojure_version = "clojure-" ^ conf.clojure_version in
      let ver = "0.4-SNAPSHOT-" ^ clojure_version ^ "-standalone" in
      let jar = "jark" ^ "-" ^ ver ^ ".jar" in
      jar

    let standalone_url = 
      let git_base = "https://github.com/downloads/icylisper/jark-server" in
      let url xs = String.concat "/" xs in
      url [git_base; standalone_jar]

    let standalone_path =
      String.concat "/" [cljr_lib (); standalone_jar]

    let install_standalone () =
      Gnet.http_get conf.http_client standalone_url standalone_path

    (* write out project.clj *)
    let setup_cljr () =
      let file = Gfile.path [C.platform.cljr ; "project.clj"] in
      let f = open_out(file) in
      let project_clj_string = String.concat
          " " ["(leiningen.core/defproject cljr.core/cljr-repo";
                "\"1.0.0\"";
                ":description \"cljr is a Clojure REPL and package management system.\"";
                ":dependencies [[org.clojure/clojure \"1.3.0\"]";
                "[swank-clojure \"1.4.0\"]]";
                "[org.clojure/java.classpath \"0.1.0\"]]";
                "[org.clojure/data.json \"0.1.1\"]]";
                "[org.clojure/tools.namespace \"0.1.0\"]]";
                "[org.clojure/tools.nrepl \"0.0.5\"]]";
                "[clj-http \"0.2.7\"]]";
                "[server-socket \"1.0.0\"]]";
                ":classpath [\"./src/\" \"./\"]";
                ":repositories nil)";] in
      fprintf f "%s\n" project_clj_string;
      close_out f

  end
