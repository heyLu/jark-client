module Lein =
  struct

    open Glist
    open Gstr
    open Jark
    open Config

    let usage =
      Gstr.unlines ["usage: jark [options] lein <args>";
                    "Plugin to call leiningen from jark"]

    let show_usage () = Gstr.pe usage

    let set_lein_pwd () = 
      Jark.nfa "jark.vm" ~f:"set-prop" ~a:["leiningen.original.pwd"; (Sys.getenv "PWD")] ()

    let dispatch args =
      let a = List.rev_append [(Sys.getenv "PWD")] args in
      Jark.nfa "jark.lein" ~f:"run-task" ~a:a ()
      (* Jark.nfa "leiningen.core" ~f:"-main" ~a:args () *)

end
