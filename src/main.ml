(*pp $PP *)

include Usage
open Jark
open Repl
open Gsys
open Gstr
open Glist
open Config

let cp cmd arg =
  Jark.require "jark.cp";
   match cmd with
   | "usage"   -> Gstr.pe cp_usage
   | "help"    -> Gstr.pe cp_usage
   | "list"    -> Jark.eval_fn "jark.cp" "ls"
   | "ls"      -> Jark.eval_fn "jark.cp" "ls"
   | "add"     -> begin
      let last_arg = Glist.last arg in
      if (Gstr.starts_with last_arg  "--") then
        Config.opts := Glist.list_to_hashtbl [last_arg; "yes"];
      Jark.cp_add arg
   end
   |  _        -> Gstr.pe cp_usage
            
let vm cmd arg =
  Config.opts := (Glist.list_to_hashtbl arg);
  match cmd with
  | "usage"   -> Gstr.pe vm_usage
  | "start"   -> Jark.vm_start()
  | "stop"    -> Jark.vm_stop()
  | "connect" -> Jark.vm_connect()
  | "stat"    -> Jark.eval_fn "jark.vm" "stats"
  | "uptime"  -> Jark.eval_fn "jark.vm" "uptime"
  | "gc"      -> Jark.eval_fn "jark.vm" "gc"
  | "threads" -> Jark.eval_fn "jark.vm" "threads"
  |  _        -> Gstr.pe vm_usage 
            
let ns cmd arg =
  Config.opts := (Glist.list_to_hashtbl arg);
  Jark.require "jark.ns";
  match cmd with
  | "usage"   -> Gstr.pe ns_usage
  | "list"    -> Jark.eval_fn "jark.ns" "list"
  | "find"    -> Jark.eval_nfa "jark.ns" "find" [(List.nth arg 0)]
  | "load"    -> Jark.ns_load (Glist.first arg)
  | "repl"    -> Jark.eval_fn "jark.ns" "list"
  |  _        -> Gstr.pe ns_usage
            
let package cmd arg =
  Config.opts := (Glist.list_to_hashtbl arg);
  Jark.require "jark.package";
  match cmd with
  | "usage"     -> Gstr.pe package_usage
  | "install"   -> Gstr.pe "install"
  | "versions"  -> Gstr.pe "versions"
  | "deps"      -> Gstr.pe "dependencies"
  | "installed" -> Gstr.pe "install a package"
  | "latest"    -> Gstr.pe "Latest"
  |  _          -> Gstr.pe package_usage
            
let swank cmd arg =
  Config.opts := (Glist.list_to_hashtbl arg);
  match cmd with
  | "usage"   -> Gstr.pe swank_usage
  | "start"   -> Jark.eval "(jark.swank/start \"0.0.0.0\" 4005)"
  |  _        -> Gstr.pe swank_usage

let repo cmd arg =
  Config.opts := (Glist.list_to_hashtbl arg);
  Jark.require "jark.package";
  match cmd with
  | "list"   -> Jark.eval_fn "jark.package" "repo-list"
  | "add "   -> Jark.eval "(jark.swank/start \"0.0.0.0\" 4005)"
  |  _       -> Gstr.pe repo_usage
        
let version = 
  "version 0.4"
 
let nfa xs =
  match (List.length xs) with 
    0 -> Gstr.pe usage
  | 1 -> Jark.eval_ns  (List.nth xs 0)
  | 2 -> Jark.eval_fn  (List.nth xs 0) (List.nth xs 1) 
  | 3 -> Jark.eval_nfa (List.nth xs 0) (List.nth xs 1) (Glist.drop 2 xs)
  | _ -> Jark.eval_nfa (List.nth xs 0) (List.nth xs 1) (Glist.drop 2 xs)

let rl () =
  let term = Unix.tcgetattr Unix.stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSANOW term;
  let line = input_line stdin in
  Gstr.pe line

let run_repl ns = 
  if Gsys.is_windows() then
    Gstr.pe "Repl not implemented yet"
  else begin
    Repl.run "user"
   end

let _ =
  try
    match (List.tl (Array.to_list Sys.argv)) with
      "vm" :: []      -> Gstr.pe vm_usage
    | "vm" :: xs      -> vm (Glist.first xs) (List.tl xs)
    | "cp" :: []      -> Gstr.pe cp_usage
    | "cp" :: xs      -> cp (Glist.first xs) (List.tl xs)
    | "ns" :: []      -> Gstr.pe ns_usage
    | "ns" :: xs      -> ns (Glist.first xs) (List.tl xs)
    | "package" :: [] -> Gstr.pe package_usage
    | "package" :: xs -> package (Glist.first xs) (List.tl xs)
    | "swank" :: []   -> Gstr.pe swank_usage
    | "swank" :: xs   -> swank (Glist.first xs) (List.tl xs)
    | "repo" :: []    -> Gstr.pe repo_usage
    | "repo" :: xs    -> repo (Glist.first xs) (List.tl xs)
    | "-s" :: []      -> Gstr.pe (input_line stdin)
    | "repl" :: []    -> run_repl "user"
    | "version" :: [] -> Gstr.pe version
    | "--version" :: [] -> Gstr.pe version
    | "-v" :: []      -> Gstr.pe version
    | "install" :: [] -> Jark.install "jark"
    |  "lein"   :: [] -> Jark.eval_fn "leiningen.core" "-main" 
    |  "lein"   :: xs -> Jark.lein xs
    | "-e" :: xs      -> Jark.eval (Glist.first xs)
    |  xs             -> nfa xs
    |  _              -> Gstr.pe usage
  with Unix.Unix_error(_, "connect", "") ->
    Gstr.pe connection_usage
