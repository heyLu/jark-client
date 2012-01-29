module Server :
  sig
    val dispatch : string -> string list -> unit

    val load : string -> unit

    val install : string list -> unit

    val show_usage : unit -> unit

  end

