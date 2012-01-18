module Repo =
  struct

    open Datatypes
    open Glist
    open Gstr
    open Jark
    open Config
    open Gopt
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let usage =
      Gstr.unlines ["usage: jark [options] repo <command> <args>";
                     "Available commands for 'repo' module:\n";
                     "    list      List current repositories\n" ;
                     "    add       --repo-name <repo-name> --repo-url <repo-url>" ;
                     "              Add repository\n" ;
                     "    remove    --repo-name <repo-name>" ;
                     "              Remove repository"]

    let show_usage args = Gstr.pe usage

    let add args =
      let repo_name = Gopt.getopt "--repo-name" () in 
      let repo_url  = Gopt.getopt "--repo-url" () in 
      if repo_name = "none" || repo_url = "none" then
        Plugin.show_cmd_usage registry "add"
      else
        Jark.nfa "jark.package" ~f:"repo-add" ~a:[repo_name; repo_url] ()

    let repo_list args =
      Jark.nfa "jark.package" ~f:"repo-list" ~fmt:ResHash ()

    let _ =
      register_fn "usage" show_usage [];

      register_fn "add" add [
        "--repo-name <repo-name> --repo-url <repo-url>";
        "Add repository"];

      register_fn "list" repo_list ["List current repositories"];

      alias_fn "list" ["ls"];
      alias_fn "usage" ["help"]

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      Plugin.dispatch registry cmd arg

end
