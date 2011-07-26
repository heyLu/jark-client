module Repl :
  sig
    val enabled : bool ref

    val run : string -> unit -> unit
  end
