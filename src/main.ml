(*pp $PP *)

include Usage
open ExtList
open OptParse
open Jark
open ExtList
open ExtString
open Repl
include Util
include Config

let cp cmd arg =
  Jark.require "jark.cp";
   match cmd with
   | "usage"   -> pe cp_usage
   | "help"    -> pe cp_usage
   | "list"    -> Jark.eval_fn "jark.cp" "ls"
   | "ls"      -> Jark.eval_fn "jark.cp" "ls"
   | "add"     -> Jark.cp_add arg
   |  _        -> pe cp_usage
            
let vm cmd arg =
  match cmd with
  | "usage"   -> pe vm_usage
  | "start"   -> Jark.vm_start (List.nth arg 1)
  | "connect" -> begin 
      Jark.vm_connect (List.nth arg 1) (String.to_int (List.nth arg 3))
  end
  | "stat"    -> Jark.eval_fn "jark.vm" "stats"
  | "uptime"  -> Jark.eval_fn "jark.vm" "uptime"
  | "gc"      -> Jark.eval_fn "jark.vm" "gc"
  | "threads" -> Jark.eval_fn "jark.vm" "threads"
  |  _        -> pe vm_usage 
            
let ns cmd arg =
  Jark.require "jark.ns";
  match cmd with
  | "usage"   -> pe ns_usage
  | "list"    -> Jark.eval_fn "jark.ns" "list"
  | "find"    -> Jark.eval_nfa "jark.ns" "find" [(List.nth arg 0)]
  | "load"    -> Jark.ns_load (List.first arg)
  | "repl"    -> Jark.eval_fn "jark.ns" "list"
  |  _        -> pe ns_usage
            
let package cmd arg =
  Jark.require "jark.package";
  match cmd with
  | "usage"     -> pe package_usage
  | "install"   -> pe "install"
  | "versions"  -> pe "versions"
  | "deps"      -> pe "dependencies"
  | "installed" -> pe "install a package"
  | "latest"    -> pe "Latest"
  |  _          -> pe package_usage
            
let swank cmd arg =
  match cmd with
  | "usage"   -> pe swank_usage
  | "start"   -> Jark.eval "(jark.swank/start \"0.0.0.0\" 4005)"
  |  _        -> pe swank_usage

let repo cmd arg =
  Jark.require "jark.package";
  match cmd with
  | "list"   -> Jark.eval_fn "jark.package" "repo-list"
  | "add "   -> Jark.eval "(jark.swank/start \"0.0.0.0\" 4005)"
  |  _       -> pe repo_usage
        
let version = 
  "version 0.4"
 
let nfa xs =
  match (List.length xs) with 
    0 -> pe usage
  | 1 -> Jark.eval_ns  (List.nth xs 0)
  | 2 -> Jark.eval_fn  (List.nth xs 0) (List.nth xs 1) 
  | 3 -> Jark.eval_nfa (List.nth xs 0) (List.nth xs 1) (List.drop 2 xs)
  | _ -> Jark.eval_nfa (List.nth xs 0) (List.nth xs 1) (List.drop 2 xs)

let _ =
  try
    match (List.tl (Array.to_list Sys.argv)) with
      "vm" :: []      -> pe vm_usage
    | "vm" :: xs      -> vm (List.first xs) (List.tl xs)
    | "cp" :: []      -> pe cp_usage
    | "cp" :: xs      -> cp (List.first xs) (List.tl xs)
    | "ns" :: []      -> pe ns_usage
    | "ns" :: xs      -> ns (List.first xs) (List.tl xs)
    | "package" :: [] -> pe package_usage
    | "package" :: xs -> package (List.first xs) (List.tl xs)
    | "swank" :: []   -> pe swank_usage
    | "swank" :: xs   -> swank (List.first xs) (List.tl xs)
    | "repo" :: []    -> pe repo_usage
    | "repo" :: xs    -> repo (List.first xs) (List.tl xs)
    | "repl" :: []    -> 
        if is_windows then
          pe "Repl not implemented yet"
        else
          Repl.run "user"
    | "version" :: [] -> pe version
    | "--version" :: [] -> pe version
    | "-v" :: []      -> pe version
    | "install" :: [] -> Jark.install "jark"
    |  "lein"   :: [] -> Jark.eval_fn "leiningen.core" "-main"
    | "-e" :: xs      -> Jark.eval (List.first xs)
    |  xs             -> nfa xs
    |  _              -> pe usage
  with Unix.Unix_error _ ->
    pe connection_usage
