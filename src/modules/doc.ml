module Doc =
  struct
    open Jark

    let show_usage args = ()

    let dispatch cmd args =
      Jark.nfa "jark.doc" ~f:cmd ~a:args ()
end
