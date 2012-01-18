module Lein =
  struct

    open Glist
    open Gstr
    open Jark
    open Config

    let show_usage () =
      Jark.nfa "leiningen.core" ~f:"-main" ()

    let set_lein_pwd () = 
      Jark.nfa "jark.vm" ~f:"set-prop" ~a:["leiningen.original.pwd"; (Sys.getenv "PWD")] ()

    let dispatch cmd args =
      let a = List.rev_append [(Sys.getenv "PWD")] (cmd :: args) in
      Jark.nfa "jark.lein" ~f:"run-task" ~a:a ()
      (* Jark.nfa "leiningen.core" ~f:"-main" ~a:args () *)

end
