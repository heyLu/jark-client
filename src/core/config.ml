(*pp $PP *)

module Config =
  struct

    open Printf
    open Datatypes
    open Gsys
    open Gnet
    open Glist
    open Gstr
    open Gfile
    open Gconf

    (* environment *)
    let global_env = ref {
      ns = "user";
      debug = false;
      host = "localhost";
      port = 9000
    }

    let set_env env =
      global_env := env

    let get_env () = !global_env

    (* platform config *)

    let (~/) x = (Sys.getenv "HOME") ^ "/" ^ x

    let windows = {
      cljr            = "c:\\cljr";
      config_dir      = "c:\\jark\\";
      jark_config_dir = "c:\\jark\\";
      config_file     = "c:\\jark\\jarkrc";
      wget_bin        = "c:\\wget.exe --user-agent jark ";
    }

    let posix = {
      cljr            = ~/ ".cljr";
      config_dir      = ~/ ".config/";
      jark_config_dir = ~/ ".config/jark/";
      config_file     = ~/ ".jarkrc";
      wget_bin        = "wget --user-agent jark ";
    }

    let platform = if Gsys.is_windows then windows else posix

    let jark_version = "jark client version 0.4"

    let path xs =
      if Gsys.is_windows then
        Gstr.join_nonempty "\\" xs
      else
        Gstr.join_nonempty "/" xs

    let cljr = platform.cljr

    let cljr_lib = path [ platform.cljr; "lib" ]

    let standalone = true

    let java_tools_path () = path [(Sys.getenv "JAVA_HOME"); "lib"; "tools.jar"]

    let component c =
      let jar prj ver = prj ^ "-" ^ ver ^ ".jar" in
      let libjar prj ver = path [cljr_lib; jar prj ver] in
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
      | "nrepl"      -> comp maven "tools.nrepl" "0.0.5"
      | "jark"       -> comp clojars "jark" "0.4"
      | "swank"      -> comp clojars "swank-clojure" "1.3.2"
      | "standalone" -> comp github "jark" "0.4-standalone"
      |  _           -> ["none" ; "none" ; "none"]

    let all_jars = ["clojure"; "contrib"; "nrepl"; "jark"; "swank"]

    let jar c =
      (List.nth (component c) 0)

    let url c =
      (List.nth (component c) 1)

    let version c =
      (List.nth (component c) 2)

    let cp_boot ()  =
      if standalone then
        jar "standalone"
      else
        String.concat ":" (List.map jar all_jars)

    let setup_cljr () =
      let file = path [platform.cljr ; "project.clj"] in
      let f = open_out(file) in
      let project_clj_string = String.concat
          " " ["(leiningen.core/defproject cljr.core/cljr-repo";
                "\"1.0.0-SNAPSHOT\"";
                ":description \"cljr is a Clojure REPL and package management system.\"";
                ":dependencies [[org.clojure/clojure \"1.2.0\"]";
                "[org.clojure/clojure-contrib \"1.2.0\"]";
                "[leiningen \"1.1.0\"]";
                "[swank-clojure \"1.3.2\"]]";
                ":classpath [\"./src/\" \"./\"]";
                ":repositories nil)";] in
      fprintf f "%s\n" project_clj_string;
      close_out f

    let install_component c =
      Gnet.http_get platform.wget_bin (url c) (jar c)

    let install_standalone () =
      install_component "standalone"

    let install_components () =
      List.iter install_component all_jars

    (* config routines *)

    let remove_config () =
      Gfile.remove (path [platform.jark_config_dir; "host"]);
      Gfile.remove (path [platform.jark_config_dir; "port"])

    let set k v () =
      let config_dir = platform.config_dir in
      let jark_config_dir = platform.jark_config_dir in
      Gfile.mkdir config_dir;
      Gfile.mkdir jark_config_dir;
      let file = path [jark_config_dir; k] in
      let f = open_out file in
      fprintf f "%s\n" v;
      close_out f

    let get_from_file file k =
      let f = open_in file in
      try
        let line = input_line f in
        close_in f;
        line
      with e ->
        close_in_noerr f;
        raise e

    let get k ?(default="") () =
      let file = path [platform.jark_config_dir; k] in
      if (not (Gfile.exists file)) && (default <> "") then
        default
      else
        get_from_file file k

    (* options *)
    let host_default = get "host" ~default:"localhost" ()

    let port_default = get "port" ~default:"9000" ()

    (* needs to be kept in sync with Datatypes.config_opts
     * it's a bit of a nuisance compared to a hashtbl, but this way the compiler
     * will check that we haven't used a wrong key or type *)
    let default_opts = {
       jvm_opts    = "-Xms256m -Xmx512m -DNOSECURITY=true";
       log_path    = "/dev/null";
       swank_port  = 4005;
       json        = false;
       remote_host = "localhost"
    }

end
