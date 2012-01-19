module Swank =
  struct

    open Glist
    open Gstr
    open Jark
    open Config
    open Gopt
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "swank"

    let start args =
      let port = Gopt.getopt "--swank-port" () in
      Jark.nfa "jark.swank" ~f:"start" ~a:["0.0.0.0"; port] ()

    let _ =
      register_fn "start" start [
        "[-s|--swank-port 4005]" ;
        "Start a swank server on given port\n"]

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      Plugin.dispatch registry cmd arg

end
