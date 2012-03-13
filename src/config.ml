(*pp $PP *)

module Config =
  struct

    open Printf
    open Optiontypes
    open Ntypes
    open Gsys
    open Gnet
    open Glist
    open Gstr
    open Gfile
    open Gconf

    let release_version = "0.4.0"

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
      config_path     = "c:\\jark\\jarkrc";
      wget_bin        = "c:\\wget.exe --user-agent jark ";
    }

    let posix = {
      cljr            = ~/ ".cljr";
      config_path     = ~/ ".cljr/jark.conf";
      wget_bin        = "wget --user-agent jark ";
    }

    let platform = if Gsys.is_windows then windows else posix

    let cljr_lib install_root () = Gfile.path [ install_root ; "lib" ]

    let clojure_version = "1.3.0"
    let server_version  = "0.4.0"

    (* path to server jar *)
        
    let server_jar install_root server_version clojure_version () =
      Gfile.path [
        cljr_lib install_root ();
        (sprintf "jark-%s-clojure-%s-standalone.jar" server_version clojure_version)
      ]

    (* options and config file *)

    let server_opts = ref {
      jvm_opts        = "-Xms256m -Xmx512m";
      log_file        = "";
      install_root    = platform.cljr;
      http_client     = platform.wget_bin;
      clojure_version = clojure_version;
      server_version  = server_version;
      classpath       = server_jar platform.cljr server_version clojure_version ();
      config_file     = platform.config_path;
      output_format   = "plain"
    }

    let get_server_opts () = !server_opts

    let set_server_opts opts = 
      server_opts := opts
        
    let set_server_opt k v = 
      let opts = get_server_opts () in
      let env  = get_env () in 
      match k with
        | "jvm_opts"        -> opts.jvm_opts <- v
        | "log_file"        -> opts.log_file <- v
        | "install_root"    -> opts.install_root <- v
        | "http_client"     -> opts.http_client <- v
        | "clojure_version" -> opts.clojure_version <- v
        | "server_version"  -> opts.server_version <- v
        | "classpath"       -> opts.classpath <- v
        | "config_file"     -> opts.config_file <- v
        | "output_format"   -> opts.output_format <- v
        | "host"            -> env.host <- v
        | "port"            -> env.port <- (int_of_string v)
        | _                 -> ()

    let valid_clojure_versions = ["1.3.0"; "1.2.1"]

    let check_valid_clojure_version ver () =
      if (List.exists (fun x -> x = ver) valid_clojure_versions) then
        true
      else
        raise (Failure ("Unsupported clojure version: " ^ ver ^ "\nSupported versions: \n" ^ (Gstr.unlines valid_clojure_versions)))

    let classpath () = 
      let opts = get_server_opts () in
      check_valid_clojure_version opts.clojure_version ();
      let main_cp = (server_jar platform.cljr opts.server_version opts.clojure_version ()) in
      main_cp

    let read_config_file set_opt config_file () =
      let skip_line s =
        let s = Gstr.strip s in
        (Gstr.starts_with s "#") ||
        (s = "")
      in
      let process_line s =
        try
          if not (skip_line s) then begin
            match Str.bounded_split (Str.regexp "=") s 2 with
            | [k; v] -> set_opt (Gstr.strip (String.lowercase k)) (Gstr.strip v)
            | _ -> raise (Failure "Bad config file line")
          end
        with _ -> begin
          print_endline ("Bad config file: " ^ config_file);
          print_endline ("Could not parse line: " ^ s);
          raise (Failure "Could not load config file")
        end
      in
      if (Gfile.exists config_file) then begin
        let config = Gfile.getlines config_file in
        List.iter process_line config
      end
      else
        ()

    let read_config () = 
      let opts = get_server_opts () in 
      read_config_file set_server_opt opts.config_file ()

    let print_config () =
      let opts = get_server_opts () in 
      let env  = get_env () in
      Gstr.pe (Gstr.unlines [
        "# copy into config file " ^ opts.config_file;
        "";
        "classpath       = " ^ opts.classpath;
        "clojure_version = " ^ opts.clojure_version;
        "config_file     = " ^ opts.config_file;
        "http_client     = " ^ opts.http_client;
        "install_root    = " ^ opts.install_root;
        "jvm_opts        = " ^ opts.jvm_opts ;
        "log_file        = " ^ opts.log_file ;
        "server_version  = " ^ opts.server_version;
        "output_format   = " ^ opts.output_format;
        "port            = " ^ (sprintf "%d" env.port);
        "host            = " ^ env.host;
        "debug           = " ^ "false";

       ])


    (* look for server jar in lib directory *)
    let server_cp install_root server_version clojure_version () =
      try
        Gfile.exists (server_jar install_root server_version clojure_version ());
      with Not_found ->
        raise (Failure ("could not find server jar in " ^ (cljr_lib install_root ())))

end
