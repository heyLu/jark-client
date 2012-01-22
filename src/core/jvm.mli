module Jvm : 
  sig
    val start : string list -> unit

    val stop : string list -> unit

    val get_pid : unit -> string
  end
