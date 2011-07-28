module Lein =
  struct

    open Glist
    open Gstr
    open Jark
    open Config

    let dispatch args =
      Jark.nfa "leiningen.core" ~f:"-main" ~a:args ()
end
