module Ns :
  sig

    val dispatch : string -> string list -> unit

    val usage : string

    val load : string -> unit

    val run : string list -> unit

  end
