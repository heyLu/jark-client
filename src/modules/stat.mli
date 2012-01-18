module Stat :
  sig

    val dispatch : string -> string list -> unit

    val usage : string

    val show_usage : unit -> unit

    val get_pid : unit -> string

  end
