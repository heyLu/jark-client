(*pp $PP *)

open Jark
open Gsys
open Gstr
open Gconf
open Gfile
open Config

open Repl
open Server
open Printf
open Optiontypes
open Ntypes
open Options
module O = Options

let usage =
  Gstr.unlines ["usage: jark OPTIONS server|repl|<plugin>|<namespace> [<command>|<function>] [<args>]";
                "OPTIONS:";
                "       -F  --force-install" ;
                "       -S  --show-config";
                "       -c  --clojure-version (1.3.0)" ;
                "      -cp  --classpath" ;
                "       -d  --debug";
                "       -e  --eval" ;
                "       -f  --config-file";
                "       -h  --host (localhost)";
                "       -i  --install-root ($HOME/.cljr)" ;
                "       -j  --jvm-opts (-Xms256m -Xmx512m)" ;
                "       -o  --output-format json|plain (plain)" ;
                "       -p  --port (9000)";
                "       -s  --server-version (0.4.0)" ;
                "       -v  --version";
                "       -w  --http-client (wget)";
                "";
                "To see available server plugins:";
                "       jark plugin list";
                "To see commands for a plugin:";
                "       jark <plugin>";
                ""]

let show_usage () =
  Gstr.pe usage

let connection_usage () =
  let env = Config.get_env () in
  Gstr.unlines [sprintf "Cannot connect to the JVM on %s:%d" env.host env.port]
        
let rl () =
  let term = Unix.tcgetattr Unix.stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSANOW term;
  let line = input_line stdin in
  Gstr.pe (Jark.eval line ()) 

let eval_stdin () =
   let buf = Buffer.create 4096 in
   try while true do Buffer.add_string buf (input_line stdin) done
   with End_of_file -> Gstr.pe (Jark.eval (Buffer.contents buf) ());;

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

let run_eval args =
  Gstr.pe (Jark.eval args ())

(* main_handler functions *)

let server_dispatch args =
  match args with
  [] -> show_usage ()
  | ns :: _ when String.contains ns '.' -> Jark.dispatch args
  | ns :: []                            -> Jark.nfa ns ()
  | ns :: f :: xs                       -> Jark.nfa ns ~f:f ~a:xs ()

let show_version () = Gstr.pe Config.jark_version

let show_plugins () =
  Jark.nfa "clojure.tools.jark.plugin" ~f:"list" ()

let run_repl ns () = 
  if Gsys.is_windows then
    Gstr.pe "REPL not implemented yet"
  else begin
    Repl.run ns ()
   end

(* alias for jark lein run args *)

let run_lein xs () =
  Jark.nfa "clojure.tools.jark.plugin.lein" ~f:"run-task" ~a:xs ()

(* handle actions that don't dispatch to a plugin *)
let main_handler m args =
  match m :: args with
  | "repl"      :: [ns]     -> run_repl ns ()
  | "repl"      :: []       -> run_repl "user" ()
  | "plugin"    :: ["list"] -> show_plugins ()
  | "lein"      :: xs       -> run_lein xs ()
  | "version"   :: []       -> show_version ()
  | xs                      -> server_dispatch xs

(* option parsing *)

let parse_argv () =
  let e = Config.get_env () in
  let (host, port, version, debug, eval, show_config) =
    (ref (e.host), ref (e.port), ref false, ref (e.debug), ref false, ref false)
  in

  let g = Config.get_server_opts () in
  let (jvm_opts, log_file, http_client) = 
    (ref (g.jvm_opts), ref (g.log_file), ref (g.http_client))
  in
  let (install_root, clojure_version, server_version) = 
    (ref (g.install_root), ref (g.clojure_version), ref (g.server_version))
  in

  let (classpath, config_file, output_format) = 
    (ref (g.classpath), ref (g.config_file), ref (g.output_format))
  in

  let rest = try
    Options.parse_argv [
    "--clojure-version", O.Set_string clojure_version, "Set clojure version";
    "--config-file",     O.Set_string config_file,         "Use the given config file (default platform.cljr)";
    "--debug",           O.Set_on debug,               "Enable debug";
    "--http-client",     O.Set_string http_client,     "Set HTTP client";
    "--install-root",    O.Set_string install_root,    "Set install root";
    "--output-format",   O.Set_string output_format,   "Set output format (json|plain)";
    "--jvm-opts",        O.Set_string jvm_opts,        "Set JVM version";
    "--prefix",          O.Set_string install_root,    "Set install root (required for debian)";
    "--show-config",     O.Set_on show_config,         "Show config";
    "--version",         O.Set_on version,             "Show jark version";
    "-S",                O.Set_on show_config,         "Show config";
    "-c",                O.Set_string clojure_version, "Set clojure version";
    "-cp",               O.Set_string classpath,       "Set classpath";
    "-w",                O.Set_string http_client,     "Set http client";
    "-f",                O.Set_string config_file,     "Use the given config file (default platform.cljr)";
    "-d",                O.Set_on debug,               "Enable debug";
    "-e",                O.Set_on eval,                "Evaluate expression";
    "-h",                O.Set_string host,            ("Set server hostname (default: " ^ !host ^ ")");
    "-i",                O.Set_string install_root,    "Set install root";
    "-j",                O.Set_string jvm_opts,        "Set JVM version";
    "-o",                O.Set_string output_format,   "Set output format (json|plain)";
    "-p",                O.Set_int port,               (sprintf "Set server port (default: %d)" !port);
    "-s",                O.Set_string server_version,  "Set jark server version";
    "-v",                O.Set_on version,             "Show jark version";
  ]
  with Options.BadOptions x -> print_endline ("bad options: " ^ x); exit 1
  in
  {
    env = {
      host = !host;
      port = !port;
      ns = "user";
      debug = !debug
    };
    show_version = !version;
    show_config = !show_config;
    eval = !eval;
    server_opts = {
      jvm_opts        = !jvm_opts;
      log_file        = !log_file;
      install_root    = !install_root;
      http_client     = !http_client;
      clojure_version = !clojure_version;
      server_version  = !server_version;
      classpath       = !classpath;
      config_file     = !config_file;
      output_format   = !output_format
    }; 
    args = rest
  }

let _ =
  try
    Config.read_config ();
    let opts = parse_argv () in
    Config.set_env opts.env;
    Config.set_server_opts opts.server_opts;

    if opts.show_version then
      show_version ()
    else if opts.show_config then
      Config.print_config ()
    else if opts.eval then
      match opts.args with
        []  -> eval_stdin ()
      | _   -> run_eval (List.hd opts.args)
    else match opts.args with
      [] -> show_usage ()
    | m :: args ->
        if Hashtbl.mem registry m then
          plugin_dispatch m args
        else if Gfile.exists m then    
          Jark.pfa "plugin.ns" ~f:"load" ~a:[m] ()        
        else
          main_handler m args
  with
  | Unix.Unix_error(_, "connect", "") ->
      Gstr.pe (connection_usage ())
  | Failure e ->
      Gstr.pe ("Fatal error: " ^ e)
