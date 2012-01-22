module Swank =
  struct

    open Glist
    open Gstr
    open Jark
    open Config
    module C = Config
    open Datatypes
    open Plugin

    let registry = Plugin.create ()
    let register_fn = Plugin.register_fn registry
    let alias_fn = Plugin.alias_fn registry

    let show_usage args = Plugin.show_usage registry "swank"

    let start args =
      let env = C.get_env () in
      Jark.nfa "jark.swank" ~f:"start" ~a:["0.0.0.0"; string_of_int env.port] ()

    let _ =
      register_fn "start" start [
        "[-s|--swank-port 4005]" ;
        "Start a swank server on given port\n"]

    let dispatch cmd arg =
      Plugin.dispatch registry cmd arg

end
