module Ns :
  sig
    val dispatch : string -> string list -> unit

    val show_usage : unit -> unit

    val load : string -> unit

    val run : string list -> unit
  end
