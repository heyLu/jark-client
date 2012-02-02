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

    let standalone = true

    let posix = {
      cljr            = ~/ ".cljr";
      config_file     = ~/ ".cljr/jark.conf";
      wget_bin        = "wget --user-agent jark ";
    }

    let platform = if Gsys.is_windows then windows else posix

    let cljr = platform.cljr

    let cljr_lib = Gfile.path [ cljr; "lib" ]

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
      let skip_line s =
        let s = Gstr.strip s in
        (Gstr.starts_with s "#") ||
        (s = "")
      in
      let process_line s =
        try
          if not (skip_line s) then begin
            match Str.bounded_split (Str.regexp ":") s 2 with
            | [k; v] -> set_option (Gstr.strip k) (Gstr.strip v)
            | _ -> raise (Failure "Bad config file line")
          end
        with _ -> begin
          print_endline ("Bad config file: " ^ platform.config_file);
          print_endline ("Could not parse line: " ^ s);
          raise (Failure "Could not load config file")
        end
      in
      if (Gfile.exists platform.config_file) then begin
        let config = Gfile.getlines platform.config_file in
        List.iter process_line config
      end
      else
        ()

    let print_config () =
      Gstr.pe (Gstr.unlines [
        "# copy into config file " ^ platform.config_file;
        "";
        "jvm_opts: " ^ global_opts.jvm_opts ;
        "log_path: " ^ global_opts.log_path ;
        "swank_port: " ^ (string_of_int global_opts.swank_port) ;
        "json: " ^ (string_of_bool global_opts.json) ;
        "remote_host: " ^ global_opts.remote_host ;
        ])
end
