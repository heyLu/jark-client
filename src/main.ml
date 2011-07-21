(*pp $PP *)

include Usage
open ExtList
open Jark
open ExtList
open ExtString
include Config
open Repl
open Gsys
open Gstr

let cp cmd arg =
  Jark.require "jark.cp";
   match cmd with
   | "usage"   -> Gstr.pe cp_usage
   | "help"    -> Gstr.pe cp_usage
   | "list"    -> Jark.eval_fn "jark.cp" "ls"
   | "ls"      -> Jark.eval_fn "jark.cp" "ls"
   | "add"     -> Jark.cp_add arg
   |  _        -> Gstr.pe cp_usage
            
let vm cmd arg =
  match cmd with
  | "usage"   -> Gstr.pe vm_usage
  | "start"   -> Jark.vm_start (List.nth arg 1)
  | "connect" -> begin 
      Jark.vm_connect (List.nth arg 1) (String.to_int (List.nth arg 3))
  end
  | "stat"    -> Jark.eval_fn "jark.vm" "stats"
  | "uptime"  -> Jark.eval_fn "jark.vm" "uptime"
  | "gc"      -> Jark.eval_fn "jark.vm" "gc"
  | "threads" -> Jark.eval_fn "jark.vm" "threads"
  |  _        -> Gstr.pe vm_usage 
            
let ns cmd arg =
  Jark.require "jark.ns";
  match cmd with
  | "usage"   -> Gstr.pe ns_usage
  | "list"    -> Jark.eval_fn "jark.ns" "list"
  | "find"    -> Jark.eval_nfa "jark.ns" "find" [(List.nth arg 0)]
  | "load"    -> Jark.ns_load (List.first arg)
  | "repl"    -> Jark.eval_fn "jark.ns" "list"
  |  _        -> Gstr.pe ns_usage
            
let package cmd arg =
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
  match cmd with
  | "usage"   -> Gstr.pe swank_usage
  | "start"   -> Jark.eval "(jark.swank/start \"0.0.0.0\" 4005)"
  |  _        -> Gstr.pe swank_usage

let repo cmd arg =
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
  | 3 -> Jark.eval_nfa (List.nth xs 0) (List.nth xs 1) (List.drop 2 xs)
  | _ -> Jark.eval_nfa (List.nth xs 0) (List.nth xs 1) (List.drop 2 xs)

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
    | "vm" :: xs      -> vm (List.first xs) (List.tl xs)
    | "cp" :: []      -> Gstr.pe cp_usage
    | "cp" :: xs      -> cp (List.first xs) (List.tl xs)
    | "ns" :: []      -> Gstr.pe ns_usage
    | "ns" :: xs      -> ns (List.first xs) (List.tl xs)
    | "package" :: [] -> Gstr.pe package_usage
    | "package" :: xs -> package (List.first xs) (List.tl xs)
    | "swank" :: []   -> Gstr.pe swank_usage
    | "swank" :: xs   -> swank (List.first xs) (List.tl xs)
    | "repo" :: []    -> Gstr.pe repo_usage
    | "repo" :: xs    -> repo (List.first xs) (List.tl xs)
    | "-s" :: []      -> Gstr.pe (input_line stdin)
    | "repl" :: []    -> run_repl "user"
    | "version" :: [] -> Gstr.pe version
    | "--version" :: [] -> Gstr.pe version
    | "-v" :: []      -> Gstr.pe version
    | "install" :: [] -> Jark.install "jark"
    |  "lein"   :: [] -> Jark.eval_fn "leiningen.core" "-main" 
    |  "lein"   :: xs -> Jark.eval_nfa "leiningen.core" "-main" xs
    | "-e" :: xs      -> Jark.eval (List.first xs)
    |  xs             -> nfa xs
    |  _              -> Gstr.pe usage
  with Unix.Unix_error _ ->
    Gstr.pe connection_usage
