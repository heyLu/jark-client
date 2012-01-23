module Repo =
  struct

    open Datatypes
    open Glist
    open Gstr
    open Jark
    open Config
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "repo"

    let add args =
      Jark.nfa "jark.package" ~f:"repo-add" ~a:args ()

    let repo_list args =
      Jark.nfa "jark.package" ~f:"repo-list" ~fmt:ResHash ()

    let _ =
      register_fn "add" add [
        "--repo-name <repo-name> --repo-url <repo-url>";
        "Add repository"];

      register_fn "list" repo_list ["List current repositories"];

      alias_fn "list" ["ls"]

    let dispatch cmd arg =
      Plugin.dispatch registry cmd arg

end
