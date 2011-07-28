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
                 "    stat     instruments instrument vms mem";
                 "    swank    start stop" ;
                 "    vm       start connect stop uptime threads gc status";
                 "";
                 "See 'jark <module>' for more information on a specific module."]

let connection_usage = 
  Gstr.unlines ["Cannot connect to the JVM on localhost:9000" ;
                 "Try vm connect --host <HOST> --port <PORT>";
                 "or specify --host / --port flags in the command"]
        
let dispatch_nfa al = 
  let arg = ref [] in
  let last_arg = Glist.last al in
  if (Gstr.starts_with last_arg  "--") then begin
    Config.opts := Glist.list_to_hashtbl [last_arg; "yes"];
    arg := (Glist.remove_last al)
  end
  else
    arg := al;
  let xs = !arg in
  match (List.length xs) with 
    0 -> Gstr.pe usage
  | 1 -> Jark.nfa (List.nth xs 0) ()
  | 2 -> Jark.nfa  (List.nth xs 0) ~f:(List.nth xs 1) ()
  | _ -> Jark.nfa (List.nth xs 0) ~f:(List.nth xs 1) ~a:(Glist.drop 2 xs) ()

let dispatch xs =
  let file = (Glist.first xs) in
  if (Gfile.exists file) then begin
    Ns.load file;
  end
  else 
    dispatch_nfa xs

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
      "vm" :: []      -> Gstr.pe Vm.usage
    | "vm" :: xs      -> Vm.dispatch (Glist.first xs) (List.tl xs)
    | "cp" :: []      -> Gstr.pe Cp.usage
    | "cp" :: xs      -> Cp.dispatch (Glist.first xs) (List.tl xs)
    | "ns" :: []      -> Gstr.pe Ns.usage
    | "ns" :: xs      -> Ns.dispatch (Glist.first xs) (List.tl xs)
    | "package" :: [] -> Gstr.pe Package.usage
    | "package" :: xs -> Package.dispatch (Glist.first xs) (List.tl xs)
    | "swank" :: []   -> Gstr.pe Swank.usage
    | "swank" :: xs   -> Swank.dispatch (Glist.first xs) (List.tl xs)
    | "stat" :: []    -> Gstr.pe Stat.usage
    | "stat" :: xs    -> Stat.dispatch (Glist.first xs) (List.tl xs)
    | "repo" :: []    -> Gstr.pe Repo.usage
    | "repo" :: xs    -> Repo.dispatch (Glist.first xs) (List.tl xs)
    | "-s" :: []      -> Gstr.pe (input_line stdin)
    | "repl" :: []    -> run_repl "user" ()
    | "version" :: [] -> Gstr.pe Config.jark_version 
    | "status" :: []  -> Vm.status ()
    | "--version" :: [] -> Gstr.pe Config.jark_version
    | "-v" :: []      -> Gstr.pe Config.jark_version
    | "install" :: [] -> Jark.install "jark"
    |  "lein"  :: [] -> Jark.nfa "leiningen.core" ~f:"-main" ()
    |  "lein" :: xs  -> Lein.dispatch xs
    | "-e" :: xs     -> Gstr.pe (Jark.eval (Glist.first xs) ())
    | "-s" :: []     -> rl()
    |  []            -> Gstr.pe usage
    |  xs            -> dispatch xs
    |  _             -> Gstr.pe usage

  with Unix.Unix_error(_, "connect", "") ->
    Gstr.pe connection_usage
