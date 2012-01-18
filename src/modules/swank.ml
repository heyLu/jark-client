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

    let usage =
      Gstr.unlines ["usage: jark [options] swank <command> <args>";
                     "Available commands for 'swank' module:\n";
                     "    start     [-s|--swank-port 4005]" ; 
                     "              Start a swank server on given port\n" ;
                     "    stop      Stop an instance of the server"]

    let show_usage args = Gstr.pe usage

    let start args =
      let port = Gopt.getopt "--swank-port" () in
      Jark.nfa "jark.swank" ~f:"start" ~a:["0.0.0.0"; port] ()

    let _ =
      register_fn "usage" show_usage [];

      register_fn "start" start [
        "[-s|--swank-port 4005]" ;
        "Start a swank server on given port\n"];

      alias_fn "usage" ["help"]

    let dispatch cmd arg =
      Gopt.opts := (Glist.list_to_hashtbl arg);
      Plugin.dispatch registry cmd arg

end
