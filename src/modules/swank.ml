module Swank =
  struct

    open Glist
    open Gstr
    open Jark
    open Config

    let usage =
      Gstr.unlines ["usage: jark [options] swank <command> <args>";
                     "Available commands for 'swank' module:\n";
                     "    start     [-s|--swank-port 4005]" ; 
                     "              Start a swank server on given port\n" ;
                     "    stop      Stop an instance of the server"]


    let start () =
      let port = Config.getopt "--swank-port" in 
      Jark.nfa "jark.swank" ~f:"start" ~a:["0.0.0.0"; port] ()

    let dispatch cmd arg =
      Config.opts := (Glist.list_to_hashtbl arg);
      match cmd with
      | "usage"   -> Gstr.pe usage
      | "start"   -> start()
      |  _        -> Gstr.pe usage

end