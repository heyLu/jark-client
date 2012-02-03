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
      clojure_version = "1.3.0";
      standalone = C.standalone
    }

    let cljr_lib () =
      Gfile.path [ conf.install_root ; "lib" ]

    let set_install_opt k v = match k with
    | "install_root"    -> conf.install_root <- v
    | "http_client"     -> conf.http_client <- v
    | "clojure_version" -> conf.clojure_version <- v
    | "standalone"      -> conf.standalone <- bool_of_string v
    | _                  -> ()

    let read_config () = C.read_config_file set_install_opt

    let component c =
      let jar prj ver = prj ^ "-" ^ ver ^ ".jar" in
      let libjar prj ver = Gfile.path [cljr_lib (); jar prj ver] in
      let url xs = String.concat "/" xs in
      let clj_base = "http://build.clojure.org/releases/org/clojure" in
      let mvn_base = "http://repo1.maven.org/maven2/org/clojure" in
      let clo_base = "http://clojars.org/repo" in
      let git_base = "https://github.com/downloads/icylisper/jark-server" in
      let clojure prj ver = url [clj_base; prj; ver; jar prj ver] in
      let maven prj ver = url [mvn_base; prj; ver; jar prj ver] in
      let clojars prj ver = url [clo_base; prj; prj; ver; jar prj ver] in
      let github prj ver = url [git_base; jar prj ver] in
      let comp urlfn prj ver = [libjar prj ver; urlfn prj ver; ver] in
      match c with
      | "clojure"    -> comp clojure "clojure" "1.2.1"
      | "contrib"    -> comp clojure "clojure-contrib" "1.2.0"
      | "nrepl"      -> comp maven   "tools.nrepl" "0.0.5"
      | "jark"       -> comp clojars "jark" "0.4"
      | "swank"      -> comp clojars "swank-clojure" "1.3.2"
      | "standalone" -> comp github  "jark" "0.4-SNAPSHOT-standalone"
      |  _           -> ["none" ; "none" ; "none"]

    let deps = ["clojure"; "contrib"; "nrepl"; "jark"; "swank"]

    let jar c     = (List.nth (component c) 0)
    let url c     = (List.nth (component c) 1)
    let version c = (List.nth (component c) 2)

    let install_component c =
      Gnet.http_get conf.http_client (url c) (jar c)

    let install_standalone () =
      install_component "standalone"

    let install_components () =
      List.iter install_component deps

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
