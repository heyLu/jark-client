(*pp $PP *)

open Jark
open Gsys
open Gstr
open Gconf
open Config

open Repl
open Server
open Installer
open Printf
open Datatypes
open Options
module O = Options

let usage =
  Gstr.unlines ["usage: jark OPTIONS server|repl|<plugin>|<namespace> [<command>|<function>] [<args>]";
                "OPTIONS:";
                "    -c  --config-file";
                "    -e  --eval" ;
                "    -f  --force-install" ;
                "    -h  --host <hostname>";
                "    -H  --http-client <wget|curl>";
                "    -i  --install-root" ;
                "    -j  --json" ;
                "    -l  --log-file" ;
                "    -o  --jvm-opts" ;
                "    -p  --port <port>";
                "    -s  --show-config";
                "    -v  --version";
                "    -V  --clojure-version <x.x.x>" ;

                "To see available server plugins:";
                "       jark plugin list";
                ""]

                 
let connection_usage () =
  let env = Config.get_env () in
  Gstr.unlines [sprintf "Cannot connect to the JVM on %s:%d" env.host env.port;
                 "Try server connect --host <HOST> --port <PORT>";
                 "or specify --host / --port flags in the command"]
        
let rl () =
  let term = Unix.tcgetattr Unix.stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSANOW term;
  let line = input_line stdin in
  Gstr.pe (Jark.eval line ()) 

let run_repl ns () = 
  if Gsys.is_windows then
    Gstr.pe "REPL not implemented yet"
  else begin
    Repl.run "user" ()
   end

(* plugin system *)
module type PLUGIN =
  sig
    val show_usage : unit -> unit
    val dispatch   : string -> string list -> unit
  end

let registry : (string, (module PLUGIN)) Hashtbl.t = Hashtbl.create 16

let register x = Hashtbl.add registry x

let _ = register "server"     (module Server: PLUGIN)

let plugin_dispatch m args =
  let module Handler = (val (Hashtbl.find registry m) : PLUGIN) in
  match args with
  [] | "usage" :: _ | "help" :: _ -> Handler.show_usage ()
  | x :: xs -> Handler.dispatch x xs

let list_server_plugins () =
  Jark.nfa "clojure.tools.jark.plugin.plugin" ~f:"list" ()

let show_usage () =
  Gstr.pe usage

let run_eval args =
  Gstr.pe (Jark.eval args ())

let server_dispatch args =
  match args with
  [] -> show_usage ()
  | ns :: _ when String.contains ns '.' -> Jark.dispatch args
  | ns :: []      -> Jark.nfa ("clojure.tools.jark.plugin." ^ ns) ()
  | ns :: f :: xs -> Jark.nfa ("clojure.tools.jark.plugin." ^ ns) ~f:f ~a:xs ()

let show_version () = Gstr.pe Config.jark_version
(* handle actions that don't dispatch to a plugin *)
let main_handler m args =
  match m :: args with
  | "repl"      :: []      -> run_repl "user" ()
  | "version"   :: []      -> show_version ()
  | xs                     -> server_dispatch xs

(* option parsing *)

let parse_argv () =
  let e = Config.get_env () in
  let (host, port, version, eval, show_config) =
    (ref (e.host), ref (e.port), ref false, ref false, ref false)
  in

  let g = Config.get_server_opts () in
  let (jvm_opts, log_file) = 
    (ref (g.jvm_opts), ref (g.log_file))
  in

  let (install_root, http_client, clojure_version) = 
    (ref (g.install_root), ref (g.http_client), ref (g.clojure_version))
  in
  
  let rest = try
    Options.parse_argv [
    "-h",                O.Set_string host,            ("Set server hostname (default: " ^ !host ^ ")");
    "-p",                O.Set_int port,               (sprintf "Set server port (default: %d)" !port);
    "-v",                O.Set_on version,             "Show jark version";
    "--version",         O.Set_on version,             "Show jark version";
    "-s",                O.Set_on show_config,         "Show config";
    "--show-config",     O.Set_on show_config,         "Show config";
    "--config-file",     O.Set_on show_config,         "Use the given config file (default platform.cljr)";
    "-c",                O.Set_on show_config,         "Use the given config file (default platform.cljr)";
    "-e",                O.Set_on eval,                "Evaluate expression";
    "--jvm-opts",        O.Set_string jvm_opts,        "Set JVM version";
    "--log-file",        O.Set_string log_file,        "Set Log path";
    "-l",                O.Set_string log_file,        "Set Log path";
    "--install-root",    O.Set_string install_root,    "Set install root";
    "-i",                O.Set_string install_root,    "Set install root";
    "--prefix",          O.Set_string install_root,    "Set install root (required for debian)";
    "--http-client",     O.Set_string http_client,     "Set HTTP client";
    "--clojure-version", O.Set_string clojure_version, "Set clojure version";
    "-V",                O.Set_string clojure_version, "Set clojure version";
  ]
  with Options.BadOptions x -> print_endline ("bad options: " ^ x); exit 1
  in
  {
    env = {
      host = !host;
      port = !port;
      ns = "user";
      debug = false
    };
    show_version = !version;
    show_config = !show_config;
    eval = !eval;
    server_opts = {
      jvm_opts        = !jvm_opts;
      log_file        = !log_file;
      install_root    = !install_root;
      http_client     = !http_client;
      clojure_version = !clojure_version
    }; 
    args = rest
  }

let _ =
  try
    Config.read_config ();
    Gconf.load ();
    let opts = parse_argv () in
    Config.set_env opts.env;
    Config.set_server_opts opts.server_opts;

    if opts.show_version then
      show_version ()
    else if opts.show_config then
      Config.print_config ()
    else if opts.eval then
      run_eval (List.hd opts.args)
    else match opts.args with
      [] -> show_usage ()
    | m :: args ->
        if Hashtbl.mem registry m then
          plugin_dispatch m args
        else
          main_handler m args
  with
  | Unix.Unix_error(_, "connect", "") ->
      Gstr.pe (connection_usage ())
  | Failure e ->
      Gstr.pe ("Fatal error: " ^ e)
