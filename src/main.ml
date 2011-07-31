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

let _ =
  try
    Gconf.load ();
    let al = (List.tl (Array.to_list Sys.argv)) in
    match al with
      "vm"        :: []      -> Gstr.pe Vm.usage
    | "vm"        :: xs      -> Vm.dispatch (Glist.first xs) (List.tl xs)
    | "cp"        :: []      -> Gstr.pe Cp.usage
    | "cp"        :: xs      -> Cp.dispatch (Glist.first xs) (List.tl xs)
    | "ns"        :: []      -> Gstr.pe Ns.usage
    | "ns"        :: xs      -> Ns.dispatch (Glist.first xs) (List.tl xs)
    | "package"   :: []      -> Gstr.pe Package.usage
    | "package"   :: xs      -> Package.dispatch (Glist.first xs) (List.tl xs)
    | "swank"     :: []      -> Gstr.pe Swank.usage
    | "swank"     :: xs      -> Swank.dispatch (Glist.first xs) (List.tl xs)
    | "stat"      :: []      -> Gstr.pe Stat.usage
    | "stat"      :: xs      -> Stat.dispatch (Glist.first xs) (List.tl xs)
    | "repo"      :: []      -> Gstr.pe Repo.usage
    | "repo"      :: xs      -> Repo.dispatch (Glist.first xs) (List.tl xs)
    | "self"      :: []      -> Gstr.pe Self.usage
    | "self"      :: xs      -> Self.dispatch (Glist.first xs) (List.tl xs)
    | "doc"       :: []      -> Gstr.pe Doc.usage
    | "doc"       :: xs      -> Doc.dispatch (Glist.first xs) (List.tl xs)
    | "-s"        :: []      -> Gstr.pe (input_line stdin)
    | "repl"      :: []      -> run_repl "user" ()
    | "version"   :: []      -> Gstr.pe Config.jark_version 
    | "status"    :: []      -> Self.status ()
    | "--version" :: []      -> Gstr.pe Config.jark_version
    | "-v"        :: []      -> Gstr.pe Config.jark_version
    | "install"   :: []      -> Self.install ()
    |  "lein"     :: []      -> Jark.nfa "leiningen.core" ~f:"-main" ()
    |  "lein"     :: xs      -> Lein.dispatch xs
    | "-e"        :: xs      -> Gstr.pe (Jark.eval (Glist.first xs) ())
    |  []                    -> Gstr.pe usage
    |  xs                    -> Ns.run xs

  with Unix.Unix_error(_, "connect", "") ->
    Gstr.pe connection_usage
