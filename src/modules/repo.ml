module Repo =
  struct

    open Glist
    open Gstr
    open Jark
    open Config
    open Gopt

    let usage =
      Gstr.unlines ["usage: jark [options] repo <command> <args>";
                     "Available commands for 'repo' module:\n";
                     "    list      List current repositories\n" ;
                     "    add       --repo-name <repo-name> --repo-url <repo-url>" ;
                     "              Add repository\n" ;
                     "    remove    --repo-name <repo-name>" ;
                     "              Remove repository"]

    let add () =
      let repo_name = Gopt.getopt "--repo-name" () in 
      let repo_url  = Gopt.getopt "--repo-url" () in 
      if repo_name = "none" then 
        Gstr.pe "repo add --repo-name <repo-name> --repo-url <repo-url"
      else if repo_url = "none" then            
        Gstr.pe "repo add --repo-name <repo-name> --repo-url <repo-url"
      else
        Jark.nfa "jark.package" ~f:"repo-add" ~a:[repo_name; repo_url] ()

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "list"    -> Jark.nfa "jark.package" ~f:"repo-list" ()
      | "add"     -> add ()
      |  _        -> Gstr.pe usage

end
