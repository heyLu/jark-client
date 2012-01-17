(*pp $PP *)

open Jark
open Gsys
open Gstr
open Gfile
open Glist
open Gconf
open Config

open Vm
open Cp
open Ns
open Package
open Repo
open Repl
open Lein
open Swank
open Stat
open Self
open Doc
open Gopt

let usage =
  Gstr.unlines ["usage: jark [-v|--version] [-h|--help]" ;
                 "            [-r|repl] [-e|--eval]" ; 
                 "            [-c|--config=<path>]" ;
                 "            [-h|--host=<hostname>] [-p|--port=<port>] <module> <command> <args>" ;
                 "";
                 "The most commonly used jark modules are:" ;
                 "    cp       list add" ;
                 "    doc      search examples comments" ;
                 "    lein     <task(s)>";
                 "    ns       list load run" ;
                 "    package  install uninstall versions deps search installed latest" ;
                 "    repl     <namespace>" ;
                 "    repo     list add remove" ;
                 "    self     install uninstall status";
                 "    stat     instruments instrument vms mem";
                 "    swank    start stop" ;
                 "    vm       start connect stop uptime threads gc status";
                 "";
                 "See 'jark <module>' for more information on a specific module."]

let connection_usage = 
  Gstr.unlines ["Cannot connect to the JVM on localhost:9000" ;
                 "Try vm connect --host <HOST> --port <PORT>";
                 "or specify --host / --port flags in the command"]
        
let rl () =
  let term = Unix.tcgetattr Unix.stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSANOW term;
  let line = input_line stdin in
  Gstr.pe (Jark.eval line ()) 

let run_repl ns () = 
  if Gsys.is_windows() then
    Gstr.pe "Repl not implemented yet"
  else begin
    Repl.run "user" ()
   end

(* plugin system *)
module type Plugin =
  sig
    val show_usage : unit -> unit
    val dispatch   : string -> string list -> unit
  end

let registry : (string, (module Plugin)) Hashtbl.t = Hashtbl.create 16

let register x = Hashtbl.add registry x

let _ = register "cp"     (module Cp: Plugin)
let _ = register "doc"    (module Doc: Plugin)
let _ = register "lein"   (module Lein: Plugin)
let _ = register "ns"     (module Ns: Plugin)
let _ = register "package"(module Package: Plugin)
let _ = register "repo"   (module Repo: Plugin)
let _ = register "self"   (module Self: Plugin)
let _ = register "stat"   (module Stat: Plugin)
let _ = register "swank"  (module Swank: Plugin)
let _ = register "vm"     (module Vm: Plugin)

let plugin_dispatch m args =
  let module Handler = (val (Hashtbl.find registry m) : Plugin) in
  match args with
    []      -> Handler.show_usage ()
  | x :: xs -> Handler.dispatch x xs

(* handle actions that don't dispatch to a plugin *)
let main_handler m args =
  match m :: args with
  | "repl"      :: []      -> run_repl "user" ()
  | "status"    :: []      -> Self.status ()
  | "version"   :: []
  | "--version" :: []
  | "-v"        :: []      -> Gstr.pe Config.jark_version
  | "install"   :: []      -> Self.install ()
  | "-e"        :: xs      -> Gstr.pe (Jark.eval (Glist.first xs) ())
  | xs                     -> Ns.run xs

let _ =
  try
    Gconf.load ();
    Gopt.default_opts := Glist.assoc_to_hashtbl(Config.default_opts);
    let al = (List.tl (Array.to_list Sys.argv)) in
    match al with
      [] -> Gstr.pe usage
    | m :: args ->
        if Hashtbl.mem registry m then
          plugin_dispatch m args
        else
          main_handler m args
  with Unix.Unix_error(_, "connect", "") ->
    Gstr.pe connection_usage
