module Lein =
  struct

    open Glist
    open Gstr
    open Jark
    open Config

    let set_lein_pwd () = 
      Jark.nfa "jark.vm" ~f:"set-prop" ~a:["leiningen.original.pwd"; (Sys.getenv "PWD")] ()

    let dispatch args =
      set_lein_pwd ();
      Jark.nfa "leiningen.core" ~f:"-main" ~a:args ()

end
