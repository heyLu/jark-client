(*pp $PP *)

open Jark
open Gsys
open Gstr
open Gconf
open Config

open Repl
open Server
open Printf
open Datatypes
open Options

let usage =
  Gstr.unlines ["usage: jark OPTIONS server|repl|<plugin>|<namespace> [<command>|<function>] [<args>]";
                "";
                "            OPTIONS:   [-e|--eval] [-c|--config=<path>]" ;
                "                       [-h|--host=<hostname>] [-p|--port=<port>]"]
                 
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
  Jark.nfa "clojure.tools.jark.plugin" ~f:"list" ()

let show_usage () =
  Gstr.pe usage;
  Gstr.pe "";
  try
    Gstr.pe "Available plugins: (see 'jark plugin list')";
    list_server_plugins ()
  with Unix.Unix_error(_, "connect", "") ->
    Gstr.pe "No server plugins"

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
  let (host, port, version, eval) =
    (ref (e.host), ref (e.port), ref false, ref false)
  in
  let rest = try
    Options.parse_argv [
      "-h", Options.Set_string host, ("Set server hostname (default: " ^ !host ^ ")");
      "-p", Options.Set_int port,    (sprintf "Set server port (default: %d)" !port);
      "-v", Options.Set_on version,  "Show jark version";
      "--version", Options.Set_on version,  "Show jark version";
      "-e", Options.Set_on eval,     "Evaluate expression";
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
    eval = !eval;
    args = rest
  }

let _ =
  try
    Gconf.load ();
    let opts = parse_argv () in
    Config.set_env opts.env;
    if opts.show_version then
      show_version ()
    else if opts.eval then
      run_eval (List.hd opts.args)
    else match opts.args with
      [] -> show_usage ()
    | m :: args ->
        if Hashtbl.mem registry m then
          plugin_dispatch m args
        else
          main_handler m args
  with Unix.Unix_error(_, "connect", "") ->
    Gstr.pe (connection_usage ())
