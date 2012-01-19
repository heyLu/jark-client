module Swank :
  sig
    val dispatch : string -> string list -> unit

    val show_usage : unit -> unit
  end
