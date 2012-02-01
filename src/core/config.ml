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

    let release_version = "0.4-pre"

    let jark_version = "jark client version " ^ release_version

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
      config_file     = "c:\\jark\\jarkrc";
      wget_bin        = "c:\\wget.exe --user-agent jark ";
    }

    let posix = {
      cljr            = ~/ ".cljr";
      config_file     = ~/ ".cljr/jark.conf";
      wget_bin        = "wget --user-agent jark ";
    }

    let platform = if Gsys.is_windows then windows else posix

    let path xs =
      if Gsys.is_windows then
        Gstr.join_nonempty "\\" xs
      else
        Gstr.join_nonempty "/" xs

    let cljr = platform.cljr

    let cljr_lib = path [ platform.cljr; "lib" ]

    let standalone = true

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
      | "standalone" -> comp github "jark" "0.4-SNAPSHOT-standalone"
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

    let install_component c =
      Gnet.http_get platform.wget_bin (url c) (jar c)

    let install_standalone () =
      install_component "standalone"

    let install_components () =
      List.iter install_component all_jars

    (* options and config file *)

    (* needs to be kept in sync with Datatypes.config_opts
     * it's a bit of a nuisance compared to a hashtbl, but this way the compiler
     * will check that we haven't used a wrong key or type *)
    let global_opts = {
       jvm_opts    = "-Xms256m -Xmx512m";
       log_path    = "/dev/null";
       swank_port  = 4005;
       json        = false;
       remote_host = "localhost"
    }

    let set_option k v = match k with
    | "jvm_opts"    -> global_opts.jvm_opts <- v
    | "log_path"    -> global_opts.log_path <- v
    | "swank_port"  -> global_opts.swank_port <- int_of_string v;
    | "json"        -> global_opts.json <- bool_of_string v;
    | "remote_host" -> global_opts.remote_host <- v;
    | _             -> ()

    let read_config_file () =
      let process_line s =
        try
          match Str.bounded_split (Str.regexp ":") s 2 with
          | [k; v] -> set_option (Gstr.strip k) (Gstr.strip v)
          | _ -> raise (Failure "Bad config file line")
        with _ -> print_endline ("Could not parse config file line " ^ s)
      in
      if (Gfile.exists platform.config_file) then begin
        let config = Gfile.getlines platform.config_file in
        List.iter process_line config
      end
      else
        ()

    let print_config () =
      Gstr.pe (Gstr.unlines [
        "jvm_opts: " ^ global_opts.jvm_opts ;
        "log_path: " ^ global_opts.log_path ;
        "swank_port: " ^ (string_of_int global_opts.swank_port) ;
        "json: " ^ (string_of_bool global_opts.json) ;
        "remote_host: " ^ global_opts.remote_host ;
        ])

    let _ =
      read_config_file ();
end
