module Stat :
  sig

    val dispatch : string -> string list -> unit

    val usage : string

    val get_pid : unit -> string

  end
